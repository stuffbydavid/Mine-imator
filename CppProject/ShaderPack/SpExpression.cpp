#include "SpExpression.hpp"

#include <QAtomicInt>

#include <cmath>
#include <random>

namespace ShaderPacks
{
	ExprValue ExprValue::Vec(int n, const float* c)
	{
		ExprValue r;
		r.type = n == 2 ? VEC2 : n == 3 ? VEC3 : n == 4 ? VEC4 : FLOAT;
		for (int i = 0; i < n && i < 4; i++)
			r.v[i] = c[i];
		return r;
	}

	ExprValue ExprValue::Mat(int n, const float* c)
	{
		ExprValue r;
		r.type = n == 2 ? MAT2 : n == 3 ? MAT3 : MAT4;
		for (int i = 0; i < n * n; i++)
			r.v[i] = c[i];
		return r;
	}

	ExprValue ExprValue::Cast(Type t) const
	{
		ExprValue r;
		r.type = t;
		int n = (t == VEC2) ? 2 : (t == VEC3) ? 3 : (t == VEC4) ? 4 : 1;
		int have = Components();
		for (int i = 0; i < n; i++)
			r.v[i] = (have == 1) ? v[0] : (i < have ? v[i] : 0.f);
		if (t == BOOL)
			r.v[0] = (v[0] != 0.f) ? 1.f : 0.f;
		else if (t == INT)
			r.v[0] = (float)(int)v[0];
		return r;
	}

	ExprValue::Type ExprValue::TypeFromName(const QString& name, bool* ok)
	{
		if (ok)
			*ok = true;
		if (name == "bool")
			return BOOL;
		if (name == "int")
			return INT;
		if (name == "float")
			return FLOAT;
		if (name == "vec2")
			return VEC2;
		if (name == "vec3")
			return VEC3;
		if (name == "vec4")
			return VEC4;
		if (ok)
			*ok = false;
		return FLOAT;
	}

	struct Expression::Node
	{
		enum Kind { NUM, IDENT, UNARY, BINARY, CALL, MEMBER };
		Kind kind;
		QString name; // Identifier, operator, function name or member
		ExprValue value;
		QVector<Node*> args;
		QString siteKey; // Unique key for smooth() state

		~Node()
		{
			for (Node* n : args)
				delete n;
		}
	};

	namespace
	{
		struct Token
		{
			enum Type { NUM, IDENT, OP, LPAREN, RPAREN, COMMA, DOT, END } type;
			QString text;
		};

		QVector<Token> Lex(const QString& s, QString* error)
		{
			QVector<Token> toks;
			int i = 0;
			while (i < s.size())
			{
				QChar c = s[i];
				if (c.isSpace())
				{
					i++;
					continue;
				}
				// Numeric member access such as matrix.2.0
				if (c.isDigit() && !toks.isEmpty() && toks.last().type == Token::DOT)
				{
					int st = i;
					while (i < s.size() && s[i].isDigit())
						i++;
					toks.append({ Token::IDENT, s.mid(st, i - st) });
					continue;
				}
				if (c.isDigit() || (c == '.' && i + 1 < s.size() && s[i + 1].isDigit() && (toks.isEmpty() || toks.last().type != Token::IDENT)))
				{
					int st = i;
					while (i < s.size() && (s[i].isDigit() || s[i] == '.'))
						i++;
					if (i < s.size() && (s[i] == 'e' || s[i] == 'E'))
					{
						i++;
						if (i < s.size() && (s[i] == '+' || s[i] == '-'))
							i++;
						while (i < s.size() && s[i].isDigit())
							i++;
					}
					if (i < s.size() && (s[i] == 'f' || s[i] == 'F'))
						i++;
					toks.append({ Token::NUM, s.mid(st, i - st) });
					continue;
				}
				if (c.isLetter() || c == '_')
				{
					int st = i;
					while (i < s.size() && (s[i].isLetterOrNumber() || s[i] == '_'))
						i++;
					toks.append({ Token::IDENT, s.mid(st, i - st) });
					continue;
				}
				if (c == '(')
				{
					toks.append({ Token::LPAREN, "(" });
					i++;
					continue;
				}
				if (c == ')')
				{
					toks.append({ Token::RPAREN, ")" });
					i++;
					continue;
				}
				if (c == ',')
				{
					toks.append({ Token::COMMA, "," });
					i++;
					continue;
				}
				if (c == '.')
				{
					toks.append({ Token::DOT, "." });
					i++;
					continue;
				}

				QString two = s.mid(i, 2);
				if (two == "==" || two == "!=" || two == "<=" || two == ">=" || two == "&&" || two == "||")
				{
					toks.append({ Token::OP, two });
					i += 2;
					continue;
				}
				if (c == QChar(0x2260))
				{
					toks.append({ Token::OP, "!=" });
					i++;
					continue;
				}
				if (c == QChar(0x2264))
				{
					toks.append({ Token::OP, "<=" });
					i++;
					continue;
				}
				if (c == QChar(0x2265))
				{
					toks.append({ Token::OP, ">=" });
					i++;
					continue;
				}
				if (QString("+-*/%<>!").contains(c))
				{
					toks.append({ Token::OP, QString(c) });
					i++;
					continue;
				}
				if (error)
					*error = "Unexpected character '" + QString(c) + "'";
				return {};
			}
			toks.append({ Token::END, "" });
			return toks;
		}

		int Precedence(const QString& op)
		{
			if (op == "*" || op == "/" || op == "%")
				return 0;
			if (op == "+" || op == "-")
				return 1;
			if (op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=")
				return 2;
			if (op == "&&" || op == "||")
				return 3;
			return -1;
		}

		struct Parser
		{
			QVector<Token> toks;
			int pos = 0;
			QString error;
			int siteCounter = 0;

			const Token& Peek() const { return toks[pos]; }

			Expression::Node* ParseExpr(int maxPrec = 3)
			{
				Expression::Node* left = ParseUnary();
				if (!left)
					return nullptr;

				while (Peek().type == Token::OP)
				{
					int prec = Precedence(Peek().text);
					if (prec < 0 || prec > maxPrec)
						break;
					QString op = Peek().text;
					pos++;
					Expression::Node* right = ParseExpr(prec - 1);
					if (!right)
					{
						delete left;
						return nullptr;
					}
					auto* n = new Expression::Node{ Expression::Node::BINARY, op, {}, { left, right }, {} };
					left = n;
				}
				return left;
			}

			Expression::Node* ParseUnary()
			{
				if (Peek().type == Token::OP && (Peek().text == "-" || Peek().text == "!"))
				{
					QString op = Peek().text;
					pos++;
					Expression::Node* operand = ParseUnary();
					if (!operand)
						return nullptr;
					return new Expression::Node{ Expression::Node::UNARY, op, {}, { operand }, {} };
				}
				return ParsePostfix();
			}

			Expression::Node* ParsePostfix()
			{
				Expression::Node* n = ParsePrimary();
				while (n && Peek().type == Token::DOT)
				{
					pos++;
					if (Peek().type != Token::IDENT)
					{
						error = "Expected member name";
						delete n;
						return nullptr;
					}
					QString member = Peek().text;
					pos++;
					n = new Expression::Node{ Expression::Node::MEMBER, member, {}, { n }, {} };
				}
				return n;
			}

			Expression::Node* ParsePrimary()
			{
				const Token& t = Peek();
				if (t.type == Token::NUM)
				{
					pos++;
					QString text = t.text;
					bool isFloat = text.contains('.') || text.contains('e') || text.contains('E') || text.endsWith('f') || text.endsWith('F');
					if (text.endsWith('f') || text.endsWith('F'))
						text.chop(1);
					auto* n = new Expression::Node{ Expression::Node::NUM, {}, {}, {}, {} };
					bool intOk = false;
					int intValue = isFloat ? 0 : text.toInt(&intOk);
					n->value = (isFloat || !intOk) ? ExprValue::Float((float)text.toDouble()) : ExprValue::Int(intValue);
					return n;
				}
				if (t.type == Token::IDENT)
				{
					QString name = t.text;
					pos++;
					if (Peek().type == Token::LPAREN)
					{
						pos++;
						auto* call = new Expression::Node{ Expression::Node::CALL, name, {}, {}, {} };
						static QAtomicInt globalSiteCounter;
						call->siteKey = name + "#" + QString::number(globalSiteCounter.fetchAndAddRelaxed(1));
						if (Peek().type != Token::RPAREN)
						{
							while (true)
							{
								Expression::Node* arg = ParseExpr();
								if (!arg)
								{
									delete call;
									return nullptr;
								}
								call->args.append(arg);
								if (Peek().type == Token::COMMA)
								{
									pos++;
									continue;
								}
								break;
							}
						}
						if (Peek().type != Token::RPAREN)
						{
							error = "Expected ) after arguments of " + name;
							delete call;
							return nullptr;
						}
						pos++;
						return call;
					}
					return new Expression::Node{ Expression::Node::IDENT, name, {}, {}, {} };
				}
				if (t.type == Token::LPAREN)
				{
					pos++;
					Expression::Node* inner = ParseExpr();
					if (!inner)
						return nullptr;
					if (Peek().type != Token::RPAREN)
					{
						error = "Expected )";
						delete inner;
						return nullptr;
					}
					pos++;
					return inner;
				}
				error = "Unexpected token '" + t.text + "'";
				return nullptr;
			}
		};

		bool IsVec(const ExprValue& v)
		{
			return v.type == ExprValue::VEC2 || v.type == ExprValue::VEC3 || v.type == ExprValue::VEC4;
		}

		// Applies a component-wise function to the arguments, broadcasting scalars.
		ExprValue Map(const QVector<ExprValue>& args, const std::function<float(const float*)>& f, bool keepInt = false)
		{
			int n = 1;
			ExprValue::Type vecType = ExprValue::FLOAT;
			bool allInt = keepInt;
			for (const ExprValue& a : args)
			{
				if (IsVec(a) && a.Components() > n)
				{
					n = a.Components();
					vecType = a.type;
				}
				if (a.type != ExprValue::INT && a.type != ExprValue::BOOL)
					allInt = false;
			}

			ExprValue r;
			r.type = (n > 1) ? vecType : (allInt ? ExprValue::INT : ExprValue::FLOAT);
			float in[8];
			for (int c = 0; c < n; c++)
			{
				for (int a = 0; a < args.size() && a < 8; a++)
					in[a] = args[a].Components() == 1 ? args[a].v[0] : (c < args[a].Components() ? args[a].v[c] : 0.f);
				r.v[c] = f(in);
				if (r.type == ExprValue::INT)
					r.v[c] = (float)(int)r.v[c];
			}
			return r;
		}

		std::mt19937& Rng()
		{
			static std::mt19937 rng(1337);
			return rng;
		}

		ExprValue Eval(const Expression::Node* node, ExprContext& ctx);

		ExprValue EvalCall(const Expression::Node* node, ExprContext& ctx)
		{
			const QString& f = node->name;
			const int n = node->args.size();

			// Lazy functions
			if (f == "if")
			{
				for (int i = 0; i + 1 < n; i += 2)
					if (Eval(node->args[i], ctx).AsBool())
						return Eval(node->args[i + 1], ctx);
				if (n % 2 == 1)
					return Eval(node->args[n - 1], ctx);
				return ExprValue::Float(0.f);
			}

			QVector<ExprValue> a;
			a.reserve(n);
			for (const Expression::Node* arg : node->args)
				a.append(Eval(arg, ctx));

			auto arg = [&](int i) { return i < a.size() ? a[i].v[0] : 0.f; };

			if (f == "smooth")
			{
				// smooth([id,] value, [halfLifeUp, [halfLifeDown]])
				int base = (n >= 4) ? 1 : 0;
				float value = arg(base);
				float up = (n > base + 1) ? arg(base + 1) : 1.f;
				float down = (n > base + 2) ? arg(base + 2) : up;

				ExprContext::Smooth& s = ctx.smooth[node->siteKey];
				if (!s.init)
				{
					s.init = true;
					s.acc = value;
				}
				else
				{
					float halfLife = (value > s.acc) ? up : down;
					if (halfLife <= 0.f)
						s.acc = value;
					else
					{
						float decay = (float)(std::log(2.0) / (halfLife * 0.1));
						float factor = 1.f - std::exp(-decay * ctx.frameTime);
						s.acc = s.acc + (value - s.acc) * factor;
					}
				}
				return ExprValue::Float(s.acc);
			}

			if (f == "vec2" || f == "vec3" || f == "vec4")
			{
				int count = f[3].digitValue();
				float c[4] = { 0, 0, 0, 0 };
				int k = 0;
				for (const ExprValue& v : a)
					for (int i = 0; i < v.Components() && k < count; i++)
						c[k++] = v.v[i];
				if (k == 1)
					for (int i = 1; i < count; i++)
						c[i] = c[0];
				return ExprValue::Vec(count, c);
			}

			if (f == "in")
			{
				for (int i = 1; i < n; i++)
					if (arg(0) == arg(i))
						return ExprValue::Bool(true);
				return ExprValue::Bool(false);
			}
			if (f == "between")
				return ExprValue::Bool(arg(0) >= arg(1) && arg(0) <= arg(2));
			if (f == "equals")
				return ExprValue::Bool(std::fabs(arg(0) - arg(1)) <= (n > 2 ? arg(2) : 0.f));
			if (f == "not")
				return ExprValue::Bool(!(a.isEmpty() ? false : a[0].AsBool()));
			if (f == "and")
			{
				bool r = true;
				for (const ExprValue& v : a)
					r = r && v.AsBool();
				return ExprValue::Bool(r);
			}
			if (f == "or")
			{
				bool r = false;
				for (const ExprValue& v : a)
					r = r || v.AsBool();
				return ExprValue::Bool(r);
			}
			if (f == "random")
				return ExprValue::Float(std::uniform_real_distribution<float>(0.f, 1.f)(Rng()));
			if (f == "randomInt")
				return ExprValue::Int((int)std::uniform_int_distribution<int>(0, 1 << 30)(Rng()));

			// Component-wise math
			if (f == "sin") return Map(a, [](const float* x) { return std::sin(x[0]); });
			if (f == "cos") return Map(a, [](const float* x) { return std::cos(x[0]); });
			if (f == "tan") return Map(a, [](const float* x) { return std::tan(x[0]); });
			if (f == "asin") return Map(a, [](const float* x) { return std::asin(x[0]); });
			if (f == "acos") return Map(a, [](const float* x) { return std::acos(x[0]); });
			if (f == "atan") return Map(a, [](const float* x) { return std::atan(x[0]); });
			if (f == "atan2") return Map(a, [](const float* x) { return std::atan2(x[0], x[1]); });
			if (f == "torad" || f == "radians") return Map(a, [](const float* x) { return x[0] * 0.017453292f; });
			if (f == "todeg" || f == "degrees") return Map(a, [](const float* x) { return x[0] * 57.29577951f; });
			if (f == "min") return Map(a, [n](const float* x) { float r = x[0]; for (int i = 1; i < n; i++) r = std::min(r, x[i]); return r; }, true);
			if (f == "max") return Map(a, [n](const float* x) { float r = x[0]; for (int i = 1; i < n; i++) r = std::max(r, x[i]); return r; }, true);
			if (f == "clamp") return Map(a, [](const float* x) { return std::min(std::max(x[0], x[1]), x[2]); }, true);
			if (f == "abs") return Map(a, [](const float* x) { return std::fabs(x[0]); }, true);
			if (f == "floor") return Map(a, [](const float* x) { return std::floor(x[0]); });
			if (f == "ceil") return Map(a, [](const float* x) { return std::ceil(x[0]); });
			if (f == "round") return Map(a, [](const float* x) { return std::round(x[0]); });
			if (f == "exp") return Map(a, [](const float* x) { return std::exp(x[0]); });
			if (f == "exp2") return Map(a, [](const float* x) { return std::exp2(x[0]); });
			if (f == "exp10") return Map(a, [](const float* x) { return std::pow(10.f, x[0]); });
			if (f == "log") return Map(a, [](const float* x) { return std::log(x[0]); });
			if (f == "log2") return Map(a, [](const float* x) { return std::log2(x[0]); });
			if (f == "log10") return Map(a, [](const float* x) { return std::log10(x[0]); });
			if (f == "pow") return Map(a, [](const float* x) { return std::pow(x[0], x[1]); });
			if (f == "sqrt") return Map(a, [](const float* x) { return std::sqrt(x[0]); });
			if (f == "inversesqrt") return Map(a, [](const float* x) { return 1.f / std::sqrt(x[0]); });
			if (f == "signum" || f == "sign") return Map(a, [](const float* x) { return x[0] > 0.f ? 1.f : (x[0] < 0.f ? -1.f : 0.f); });
			if (f == "frac") return Map(a, [](const float* x) { return x[0] - std::floor(x[0]); });
			if (f == "fmod") return Map(a, [](const float* x) { return x[1] == 0.f ? 0.f : std::fmod(x[0], x[1]); });
			if (f == "mix") return Map(a, [](const float* x) { return x[0] + (x[1] - x[0]) * x[2]; });
			if (f == "edge") return Map(a, [](const float* x) { return x[1] < x[0] ? 0.f : 1.f; });

			LogWarning("Unknown function in custom uniform expression: " + f);
			return ExprValue::Float(0.f);
		}

		ExprValue Binary(const QString& op, const ExprValue& l, const ExprValue& r)
		{
			if (op == "&&")
				return ExprValue::Bool(l.AsBool() && r.AsBool());
			if (op == "||")
				return ExprValue::Bool(l.AsBool() || r.AsBool());
			if (op == "==")
				return ExprValue::Bool(l.v[0] == r.v[0]);
			if (op == "!=")
				return ExprValue::Bool(l.v[0] != r.v[0]);
			if (op == "<")
				return ExprValue::Bool(l.v[0] < r.v[0]);
			if (op == ">")
				return ExprValue::Bool(l.v[0] > r.v[0]);
			if (op == "<=")
				return ExprValue::Bool(l.v[0] <= r.v[0]);
			if (op == ">=")
				return ExprValue::Bool(l.v[0] >= r.v[0]);

			bool intMath = (l.type == ExprValue::INT || l.type == ExprValue::BOOL) && (r.type == ExprValue::INT || r.type == ExprValue::BOOL);
			QVector<ExprValue> args = { l, r };

			if (op == "+")
				return Map(args, [](const float* x) { return x[0] + x[1]; }, intMath);
			if (op == "-")
				return Map(args, [](const float* x) { return x[0] - x[1]; }, intMath);
			if (op == "*")
				return Map(args, [](const float* x) { return x[0] * x[1]; }, intMath);
			if (op == "/")
			{
				if (intMath)
					return ExprValue::Int(r.v[0] == 0.f ? 0 : (int)l.v[0] / (int)r.v[0]);
				return Map(args, [](const float* x) { return x[1] == 0.f ? 0.f : x[0] / x[1]; });
			}
			if (op == "%")
			{
				if (intMath)
					return ExprValue::Int(r.v[0] == 0.f ? 0 : (int)l.v[0] % (int)r.v[0]);
				return Map(args, [](const float* x) { return x[1] == 0.f ? 0.f : std::fmod(x[0], x[1]); });
			}
			return ExprValue::Float(0.f);
		}

		ExprValue Eval(const Expression::Node* node, ExprContext& ctx)
		{
			switch (node->kind)
			{
				case Expression::Node::NUM:
					return node->value;

				case Expression::Node::IDENT:
				{
					if (node->name == "true")
						return ExprValue::Bool(true);
					if (node->name == "false")
						return ExprValue::Bool(false);
					if (node->name == "pi")
						return ExprValue::Float(3.14159265358979f);
					ExprValue v;
					if (ctx.lookup && ctx.lookup(node->name, v))
						return v;
					return ExprValue::Float(0.f);
				}

				case Expression::Node::UNARY:
				{
					ExprValue v = Eval(node->args[0], ctx);
					if (node->name == "!")
						return ExprValue::Bool(!v.AsBool());
					for (int i = 0; i < 4; i++)
						v.v[i] = -v.v[i];
					if (v.type == ExprValue::BOOL)
						v.type = ExprValue::INT;
					return v;
				}

				case Expression::Node::BINARY:
				{
					// Short-circuit logic
					if (node->name == "&&")
					{
						if (!Eval(node->args[0], ctx).AsBool())
							return ExprValue::Bool(false);
						return ExprValue::Bool(Eval(node->args[1], ctx).AsBool());
					}
					if (node->name == "||")
					{
						if (Eval(node->args[0], ctx).AsBool())
							return ExprValue::Bool(true);
						return ExprValue::Bool(Eval(node->args[1], ctx).AsBool());
					}
					return Binary(node->name, Eval(node->args[0], ctx), Eval(node->args[1], ctx));
				}

				case Expression::Node::CALL:
					return EvalCall(node, ctx);

				case Expression::Node::MEMBER:
				{
					ExprValue v = Eval(node->args[0], ctx);
					static const QString sets[3] = { "xyzw", "rgba", "stpq" };
					const QString& m = node->name;

					// Numeric index: column of a matrix or component of a vector
					if (!m.isEmpty() && m[0].isDigit())
					{
						int index = m.toInt();
						int size = v.MatrixSize();
						if (size > 0)
						{
							float col[4] = { 0, 0, 0, 0 };
							if (index < size)
								for (int r = 0; r < size; r++)
									col[r] = v.v[index * size + r];
							return ExprValue::Vec(size, col);
						}
						return ExprValue::Float(index < 4 ? v.v[index] : 0.f);
					}

					float c[4];
					int count = 0;
					for (QChar ch : m)
					{
						int idx = -1;
						for (const QString& set : sets)
							if (set.indexOf(ch) >= 0)
								idx = set.indexOf(ch);
						if (idx < 0 || count >= 4)
							break;
						c[count++] = v.v[idx];
					}
					if (count == 1)
						return ExprValue::Float(c[0]);
					return ExprValue::Vec(count, c);
				}
			}
			return ExprValue::Float(0.f);
		}

		void CollectRefs(const Expression::Node* node, QSet<QString>& refs)
		{
			if (node->kind == Expression::Node::IDENT)
				refs.insert(node->name);
			for (const Expression::Node* a : node->args)
				CollectRefs(a, refs);
		}
	}

	Expression::~Expression()
	{
		delete root;
	}

	std::shared_ptr<Expression> Expression::Parse(const QString& text, QString* error)
	{
		QString lexError;
		QVector<Token> toks = Lex(text, &lexError);
		if (toks.isEmpty())
		{
			if (error)
				*error = lexError;
			return nullptr;
		}

		Parser parser;
		parser.toks = toks;
		Node* root = parser.ParseExpr();
		if (!root || parser.Peek().type != Token::END)
		{
			if (error)
				*error = parser.error.isEmpty() ? "Unexpected trailing tokens" : parser.error;
			delete root;
			return nullptr;
		}

		auto expr = std::make_shared<Expression>();
		expr->root = root;
		expr->text = text;
		return expr;
	}

	ExprValue Expression::Evaluate(ExprContext& ctx) const
	{
		return root ? Eval(root, ctx) : ExprValue::Float(0.f);
	}

	QSet<QString> Expression::References() const
	{
		QSet<QString> refs;
		if (root)
			CollectRefs(root, refs);
		return refs;
	}

	bool EvaluateBooleanOptionExpression(const QString& expr, const std::function<bool(const QString&)>& lookup)
	{
		// Same grammar as custom expressions restricted to identifiers, !, &&, || and parentheses
		ExprContext ctx;
		ctx.lookup = [&](const QString& name, ExprValue& out)
		{
			out = ExprValue::Bool(lookup(name));
			return true;
		};

		if (expr.trimmed().isEmpty())
			return true;

		QString error;
		auto parsed = Expression::Parse(expr, &error);
		if (!parsed)
		{
			LogWarning("Could not parse boolean expression \"" + expr + "\": " + error + ", defaulting to true");
			return true;
		}
		return parsed->Evaluate(ctx).AsBool();
	}
}
