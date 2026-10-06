#include "SpPreprocessor.hpp"

#include <QRegularExpression>

#include <algorithm>
#include <cmath>
#include <cstring>

namespace ShaderPacks
{
	namespace
	{
		enum TokType : uint8_t
		{
			T_WS,
			T_NEWLINE,
			T_COMMENT,
			T_IDENT,
			T_NUMBER,
			T_STRING,
			T_PUNCT,
			T_OTHER
		};

		// Set of macro ids that may not be expanded for a token (Prosser's algorithm)
		using HideSet = std::shared_ptr<const std::vector<int>>;

		struct Tok
		{
			TokType type;
			QString text;
			HideSet hide;
		};

		bool HideContains(const HideSet& hs, int id)
		{
			return hs && std::binary_search(hs->begin(), hs->end(), id);
		}

		HideSet HideAdd(const HideSet& hs, int id)
		{
			if (HideContains(hs, id))
				return hs;
			auto v = std::make_shared<std::vector<int>>();
			if (hs)
				*v = *hs;
			v->insert(std::lower_bound(v->begin(), v->end(), id), id);
			return v;
		}

		HideSet HideUnion(const HideSet& a, const HideSet& b)
		{
			if (!a || a->empty())
				return b;
			if (!b || b->empty() || a == b)
				return a;
			auto v = std::make_shared<std::vector<int>>();
			std::set_union(a->begin(), a->end(), b->begin(), b->end(), std::back_inserter(*v));
			return v;
		}

		HideSet HideIntersect(const HideSet& a, const HideSet& b)
		{
			if (!a || !b || a->empty() || b->empty())
				return nullptr;
			if (a == b)
				return a;
			auto v = std::make_shared<std::vector<int>>();
			std::set_intersection(a->begin(), a->end(), b->begin(), b->end(), std::back_inserter(*v));
			return v;
		}

		inline bool IsIdentStart(QChar c)
		{
			return c.isLetter() || c == '_';
		}

		inline bool IsIdentChar(QChar c)
		{
			return c.isLetterOrNumber() || c == '_';
		}

		// Splits source text into preprocessing tokens. Backslash-newline sequences are removed.
		QVector<Tok> Tokenize(const QString& src, bool stringsEndAtNewline)
		{
			QVector<Tok> toks;
			toks.reserve(src.size() / 3);
			const int n = src.size();
			int i = 0;

			static const char* puncts3[] = { "<<=", ">>=", "..." };
			static const char* puncts2[] = { "##", "<<", ">>", "<=", ">=", "==", "!=", "&&", "||", "^^", "++", "--",
				"+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=", "->" };

			while (i < n)
			{
				QChar c = src[i];

				// Line continuation
				if (c == '\\' && i + 1 < n && (src[i + 1] == '\n' || (src[i + 1] == '\r' && i + 2 < n && src[i + 2] == '\n')))
				{
					i += (src[i + 1] == '\r') ? 3 : 2;
					toks.append({ T_WS, " ", nullptr });
					continue;
				}

				if (c == '\n')
				{
					static const QString newline("\n");
					toks.append({ T_NEWLINE, newline, nullptr });
					i++;
					continue;
				}

				if (c == '\r')
				{
					i++;
					continue;
				}

				if (c == ' ' || c == '\t' || c == '\f' || c == '\v' || c.unicode() == 0)
				{
					int s = i;
					while (i < n && (src[i] == ' ' || src[i] == '\t' || src[i] == '\f' || src[i] == '\v' || src[i].unicode() == 0))
						i++;
					static const QString oneSpace(" "), oneTab("\t");
					if (i - s == 1 && src[s] == ' ')
						toks.append({ T_WS, oneSpace, nullptr });
					else if (i - s == 1 && src[s] == '\t')
						toks.append({ T_WS, oneTab, nullptr });
					else
						toks.append({ T_WS, src.mid(s, i - s).remove(QChar(0)), nullptr });
					continue;
				}

				// Comments
				if (c == '/' && i + 1 < n)
				{
					if (src[i + 1] == '/')
					{
						int s = i;
						while (i < n && src[i] != '\n')
						{
							// A backslash at the end of a line comment continues it
							if (src[i] == '\\' && i + 1 < n && src[i + 1] == '\n')
								i++;
							i++;
						}
						QString text = src.mid(s, i - s);
						text.remove('\r');
						toks.append({ T_COMMENT, text, nullptr });
						continue;
					}
					if (src[i + 1] == '*')
					{
						int s = i;
						int e = src.indexOf("*/", i + 2);
						i = (e < 0) ? n : e + 2;
						QString text = src.mid(s, i - s);
						text.remove('\r');
						toks.append({ T_COMMENT, text, nullptr });
						continue;
					}
				}

				if (IsIdentStart(c))
				{
					int s = i;
					while (i < n && IsIdentChar(src[i]))
						i++;
					toks.append({ T_IDENT, src.mid(s, i - s), nullptr });
					continue;
				}

				// pp-number
				if (c.isDigit() || (c == '.' && i + 1 < n && src[i + 1].isDigit()))
				{
					int s = i;
					i++;
					while (i < n)
					{
						QChar d = src[i];
						if ((d == '+' || d == '-') && (src[i - 1] == 'e' || src[i - 1] == 'E' || src[i - 1] == 'p' || src[i - 1] == 'P'))
						{
							// Only treat as exponent sign for decimal-looking numbers
							if (!src.mid(s, 2).startsWith("0x", Qt::CaseInsensitive) || src[i - 1] == 'p' || src[i - 1] == 'P')
							{
								i++;
								continue;
							}
						}
						if (IsIdentChar(d) || d == '.')
						{
							i++;
							continue;
						}
						break;
					}
					toks.append({ T_NUMBER, src.mid(s, i - s), nullptr });
					continue;
				}

				if (c == '"' || c == '\'')
				{
					int s = i;
					i++;
					while (i < n && src[i] != c)
					{
						if (src[i] == '\n' && stringsEndAtNewline)
							break;
						if (src[i] == '\\')
							i++;
						i++;
					}
					if (i < n && src[i] == c)
						i++;
					toks.append({ T_STRING, src.mid(s, i - s), nullptr });
					continue;
				}

				// Punctuators
				{
					static const QString three[] = { "<<=", ">>=", "..." };
					static const QString two[] = { "##", "<<", ">>", "<=", ">=", "==", "!=", "&&", "||", "^^", "++", "--",
						"+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=", "->" };
					static QString single[128];
					static bool singleInit = false;
					if (!singleInit)
					{
						for (int ch = 0; ch < 128; ch++)
							single[ch] = QString(QChar(ch));
						singleInit = true;
					}

					ushort u = c.unicode();
					ushort u1 = (i + 1 < n) ? src[i + 1].unicode() : 0;
					ushort u2 = (i + 2 < n) ? src[i + 2].unicode() : 0;

					const QString* matched = nullptr;
					int len = 0;
					if ((u == '<' && u1 == '<' && u2 == '=') )
						matched = &three[0], len = 3;
					else if (u == '>' && u1 == '>' && u2 == '=')
						matched = &three[1], len = 3;
					else if (u == '.' && u1 == '.' && u2 == '.')
						matched = &three[2], len = 3;
					else if (u1)
					{
						for (const QString& t : two)
						{
							if (t[0].unicode() == u && t[1].unicode() == u1)
							{
								matched = &t;
								len = 2;
								break;
							}
						}
					}

					if (matched)
					{
						toks.append({ T_PUNCT, *matched, nullptr });
						i += len;
						continue;
					}

					if (u < 128 && strchr("()[]{}.,;:?~!%^&*+-=|/<>#", (char)u))
						toks.append({ T_PUNCT, single[u], nullptr });
					else
						toks.append({ T_OTHER, QString(c), nullptr });
				}
				i++;
			}

			return toks;
		}

		inline bool IsSpace(const Tok& t)
		{
			return t.type == T_WS || t.type == T_COMMENT;
		}

		// Value used when evaluating #if expressions
		struct Value
		{
			bool isFloat = false;
			long long i = 0;
			double f = 0.0;

			double AsFloat() const { return isFloat ? f : (double)i; }
			long long AsInt() const { return isFloat ? (long long)f : i; }
			bool AsBool() const { return isFloat ? (f != 0.0) : (i != 0); }

			static Value Int(long long v) { Value r; r.i = v; return r; }
			static Value Float(double v) { Value r; r.isFloat = true; r.f = v; return r; }
		};

		// Recursive descent evaluator for preprocessor conditions
		struct ExprParser
		{
			const QVector<Tok>& toks;
			int pos = 0;
			bool error = false;

			ExprParser(const QVector<Tok>& t) : toks(t) {}

			const Tok* Peek()
			{
				return pos < toks.size() ? &toks[pos] : nullptr;
			}

			bool Accept(const char* punct)
			{
				const Tok* t = Peek();
				if (t && t->type == T_PUNCT && t->text == QLatin1String(punct))
				{
					pos++;
					return true;
				}
				return false;
			}

			Value Parse()
			{
				Value v = Ternary();
				if (pos < toks.size())
					error = true;
				return v;
			}

			Value Ternary()
			{
				Value c = LogicalOr();
				if (Accept("?"))
				{
					Value a = Ternary();
					if (!Accept(":"))
					{
						error = true;
						return c;
					}
					Value b = Ternary();
					return c.AsBool() ? a : b;
				}
				return c;
			}

			Value LogicalOr()
			{
				Value l = LogicalAnd();
				while (Accept("||") || Accept("^^"))
				{
					bool isXor = toks[pos - 1].text == "^^";
					Value r = LogicalAnd();
					l = Value::Int(isXor ? (l.AsBool() != r.AsBool()) : (l.AsBool() || r.AsBool()));
				}
				return l;
			}

			Value LogicalAnd()
			{
				Value l = BitOr();
				while (Accept("&&"))
				{
					Value r = BitOr();
					l = Value::Int(l.AsBool() && r.AsBool());
				}
				return l;
			}

			Value BitOr()
			{
				Value l = BitXor();
				while (true)
				{
					const Tok* t = Peek();
					if (t && t->type == T_PUNCT && t->text == "|")
					{
						pos++;
						Value r = BitXor();
						l = Value::Int(l.AsInt() | r.AsInt());
					}
					else
						break;
				}
				return l;
			}

			Value BitXor()
			{
				Value l = BitAnd();
				while (Accept("^"))
				{
					Value r = BitAnd();
					l = Value::Int(l.AsInt() ^ r.AsInt());
				}
				return l;
			}

			Value BitAnd()
			{
				Value l = Equality();
				while (true)
				{
					const Tok* t = Peek();
					if (t && t->type == T_PUNCT && t->text == "&")
					{
						pos++;
						Value r = Equality();
						l = Value::Int(l.AsInt() & r.AsInt());
					}
					else
						break;
				}
				return l;
			}

			Value Equality()
			{
				Value l = Relational();
				while (true)
				{
					if (Accept("=="))
					{
						Value r = Relational();
						l = Value::Int((l.isFloat || r.isFloat) ? (l.AsFloat() == r.AsFloat()) : (l.i == r.i));
					}
					else if (Accept("!="))
					{
						Value r = Relational();
						l = Value::Int((l.isFloat || r.isFloat) ? (l.AsFloat() != r.AsFloat()) : (l.i != r.i));
					}
					else
						break;
				}
				return l;
			}

			Value Relational()
			{
				Value l = Shift();
				while (true)
				{
					if (Accept("<="))
					{
						Value r = Shift();
						l = Value::Int(l.AsFloat() <= r.AsFloat());
					}
					else if (Accept(">="))
					{
						Value r = Shift();
						l = Value::Int(l.AsFloat() >= r.AsFloat());
					}
					else if (Accept("<"))
					{
						Value r = Shift();
						l = Value::Int(l.AsFloat() < r.AsFloat());
					}
					else if (Accept(">"))
					{
						Value r = Shift();
						l = Value::Int(l.AsFloat() > r.AsFloat());
					}
					else
						break;
				}
				return l;
			}

			Value Shift()
			{
				Value l = Additive();
				while (true)
				{
					if (Accept("<<"))
					{
						Value r = Additive();
						l = Value::Int(l.AsInt() << r.AsInt());
					}
					else if (Accept(">>"))
					{
						Value r = Additive();
						l = Value::Int(l.AsInt() >> r.AsInt());
					}
					else
						break;
				}
				return l;
			}

			Value Additive()
			{
				Value l = Multiplicative();
				while (true)
				{
					if (Accept("+"))
					{
						Value r = Multiplicative();
						l = (l.isFloat || r.isFloat) ? Value::Float(l.AsFloat() + r.AsFloat()) : Value::Int(l.i + r.i);
					}
					else if (Accept("-"))
					{
						Value r = Multiplicative();
						l = (l.isFloat || r.isFloat) ? Value::Float(l.AsFloat() - r.AsFloat()) : Value::Int(l.i - r.i);
					}
					else
						break;
				}
				return l;
			}

			Value Multiplicative()
			{
				Value l = Unary();
				while (true)
				{
					if (Accept("*"))
					{
						Value r = Unary();
						l = (l.isFloat || r.isFloat) ? Value::Float(l.AsFloat() * r.AsFloat()) : Value::Int(l.i * r.i);
					}
					else if (Accept("/"))
					{
						Value r = Unary();
						if (l.isFloat || r.isFloat)
							l = Value::Float(r.AsFloat() == 0.0 ? 0.0 : l.AsFloat() / r.AsFloat());
						else
							l = Value::Int(r.i == 0 ? 0 : l.i / r.i);
					}
					else if (Accept("%"))
					{
						Value r = Unary();
						if (l.isFloat || r.isFloat)
							l = Value::Float(r.AsFloat() == 0.0 ? 0.0 : std::fmod(l.AsFloat(), r.AsFloat()));
						else
							l = Value::Int(r.i == 0 ? 0 : l.i % r.i);
					}
					else
						break;
				}
				return l;
			}

			Value Unary()
			{
				if (Accept("!"))
					return Value::Int(!Unary().AsBool());
				if (Accept("-"))
				{
					Value v = Unary();
					return v.isFloat ? Value::Float(-v.f) : Value::Int(-v.i);
				}
				if (Accept("+"))
					return Unary();
				if (Accept("~"))
					return Value::Int(~Unary().AsInt());
				return Primary();
			}

			Value Primary()
			{
				if (Accept("("))
				{
					Value v = Ternary();
					if (!Accept(")"))
						error = true;
					return v;
				}

				const Tok* t = Peek();
				if (!t)
				{
					error = true;
					return Value();
				}
				pos++;

				if (t->type == T_NUMBER)
					return ParseNumber(t->text);

				if (t->type == T_IDENT)
				{
					// Undefined identifiers evaluate to 0, GLSL style true/false are allowed
					if (t->text == "true")
						return Value::Int(1);
					return Value::Int(0);
				}

				error = true;
				return Value();
			}

			Value ParseNumber(QString text)
			{
				bool ok = false;
				QString lower = text.toLower();

				if (lower.startsWith("0x"))
				{
					while (lower.endsWith('u') || lower.endsWith('l'))
						lower.chop(1);
					long long v = lower.mid(2).toLongLong(&ok, 16);
					return Value::Int(ok ? v : 0);
				}

				bool isFloat = lower.contains('.') || lower.contains('e') || lower.endsWith('f');
				if (isFloat)
				{
					while (lower.endsWith('f') || lower.endsWith("lf"))
						lower.chop(lower.endsWith("lf") ? 2 : 1);
					double v = lower.toDouble(&ok);
					return Value::Float(ok ? v : 0.0);
				}

				while (lower.endsWith('u') || lower.endsWith('l'))
					lower.chop(1);

				long long v;
				if (lower.size() > 1 && lower.startsWith('0'))
					v = lower.toLongLong(&ok, 8);
				else
					v = lower.toLongLong(&ok, 10);
				return Value::Int(ok ? v : 0);
			}
		};
	}

	struct Preprocessor::Impl
	{
		struct Macro
		{
			int id = 0;
			bool function = false;
			bool variadic = false;
			QStringList params;
			QVector<Tok> body;
		};

		QHash<QString, Macro> macros;
		int nextMacroId = 1;

		struct CondState
		{
			bool parentActive;
			bool active;
			bool taken;
			bool seenElse;
		};

		static QVector<Tok> Trim(const QVector<Tok>& toks)
		{
			int s = 0, e = toks.size();
			while (s < e && (IsSpace(toks[s]) || toks[s].type == T_NEWLINE))
				s++;
			while (e > s && (IsSpace(toks[e - 1]) || toks[e - 1].type == T_NEWLINE))
				e--;
			return toks.mid(s, e - s);
		}

		void DefineFromTokens(const QVector<Tok>& line, QStringList& errors)
		{
			// line: tokens after "define"
			int p = 0;
			while (p < line.size() && IsSpace(line[p]))
				p++;
			if (p >= line.size() || line[p].type != T_IDENT)
			{
				errors.append("Invalid #define");
				return;
			}

			Macro m;
			m.id = nextMacroId++;
			QString name = line[p].text;
			p++;

			// Function-like macro: '(' immediately after name
			if (p < line.size() && line[p].type == T_PUNCT && line[p].text == "(")
			{
				m.function = true;
				p++;
				while (p < line.size())
				{
					const Tok& t = line[p];
					if (IsSpace(t) || (t.type == T_PUNCT && t.text == ","))
					{
						p++;
						continue;
					}
					if (t.type == T_PUNCT && t.text == ")")
					{
						p++;
						break;
					}
					if (t.type == T_IDENT)
						m.params.append(t.text);
					else if (t.type == T_PUNCT && t.text == "...")
						m.variadic = true;
					p++;
				}
			}

			QVector<Tok> body;
			for (; p < line.size(); p++)
			{
				if (line[p].type == T_COMMENT)
				{
					body.append({ T_WS, " ", nullptr });
					continue;
				}
				body.append(line[p]);
			}
			m.body = Trim(body);

			if (macros.contains(name))
				m.id = macros[name].id;
			macros[name] = m;
		}

		// Expands all macros in the token list.
		QVector<Tok> Expand(const QVector<Tok>& input, bool resolveDefined = false)
		{
			QVector<Tok> output;
			output.reserve(input.size());

			std::vector<Tok> stack;
			stack.reserve(input.size());
			for (int i = input.size() - 1; i >= 0; i--)
				stack.push_back(input[i]);

			while (!stack.empty())
			{
				Tok t = std::move(stack.back());
				stack.pop_back();

				if (t.type != T_IDENT)
				{
					output.append(std::move(t));
					continue;
				}

				// defined X / defined(X) in conditions
				if (resolveDefined && t.text == "defined")
				{
					int k = (int)stack.size() - 1;
					while (k >= 0 && IsSpace(stack[k]))
						k--;
					bool paren = false;
					if (k >= 0 && stack[k].type == T_PUNCT && stack[k].text == "(")
					{
						paren = true;
						k--;
						while (k >= 0 && IsSpace(stack[k]))
							k--;
					}
					if (k >= 0 && stack[k].type == T_IDENT)
					{
						bool def = macros.contains(stack[k].text);
						int end = k;
						if (paren)
						{
							end--;
							while (end >= 0 && IsSpace(stack[end]))
								end--;
							if (end < 0 || stack[end].type != T_PUNCT || stack[end].text != ")")
							{
								output.append(t);
								continue;
							}
						}
						stack.resize(end);
						output.append({ T_NUMBER, def ? "1" : "0", nullptr });
						continue;
					}
					output.append(t);
					continue;
				}

				auto it = macros.constFind(t.text);
				if (it == macros.constEnd() || HideContains(t.hide, it->id))
				{
					output.append(std::move(t));
					continue;
				}

				const Macro& m = *it;

				if (!m.function)
				{
					HideSet hs = HideAdd(t.hide, m.id);
					for (int i = m.body.size() - 1; i >= 0; i--)
					{
						Tok b = m.body[i];
						b.hide = HideUnion(b.hide, hs);
						stack.push_back(std::move(b));
					}
					continue;
				}

				// Function-like macro, check for an opening parenthesis
				int k = (int)stack.size() - 1;
				while (k >= 0 && (IsSpace(stack[k]) || stack[k].type == T_NEWLINE))
					k--;
				if (k < 0 || stack[k].type != T_PUNCT || stack[k].text != "(")
				{
					output.append(std::move(t));
					continue;
				}

				// Collect arguments
				int newlines = 0;
				for (int j = (int)stack.size() - 1; j > k; j--)
					if (stack[j].type == T_NEWLINE)
						newlines++;
				stack.resize(k); // Remove '(' and preceding whitespace

				QVector<QVector<Tok>> args;
				QVector<Tok> current;
				int depth = 0;
				bool closed = false;
				Tok closing;

				while (!stack.empty())
				{
					Tok a = std::move(stack.back());
					stack.pop_back();

					if (a.type == T_NEWLINE)
					{
						newlines++;
						current.append({ T_WS, " ", nullptr });
						continue;
					}

					if (a.type == T_PUNCT)
					{
						if (a.text == "(")
							depth++;
						else if (a.text == ")")
						{
							if (depth == 0)
							{
								closed = true;
								closing = a;
								break;
							}
							depth--;
						}
						else if (a.text == "," && depth == 0 && !(m.variadic && args.size() >= m.params.size()))
						{
							args.append(current);
							current.clear();
							continue;
						}
					}
					current.append(std::move(a));
				}

				if (!closed)
				{
					output.append(t);
					continue;
				}

				args.append(current);

				// Zero-parameter macro called with ()
				if (m.params.isEmpty() && !m.variadic && args.size() == 1 && Trim(args[0]).isEmpty())
					args.clear();

				// Pre-expand arguments
				QVector<QVector<Tok>> expandedArgs;
				for (const QVector<Tok>& arg : args)
					expandedArgs.append(Expand(Trim(arg), resolveDefined));

				// Substitute
				QVector<Tok> body;
				for (const Tok& b : m.body)
				{
					if (b.type == T_IDENT)
					{
						int idx = m.params.indexOf(b.text);
						if (idx >= 0)
						{
							if (idx < expandedArgs.size())
								body += expandedArgs[idx];
							continue;
						}
						if (m.variadic && b.text == "__VA_ARGS__")
						{
							for (int a = m.params.size(); a < expandedArgs.size(); a++)
							{
								if (a > m.params.size())
									body.append({ T_PUNCT, ",", nullptr });
								body += expandedArgs[a];
							}
							continue;
						}
					}
					body.append(b);
				}

				HideSet hs = HideAdd(HideIntersect(t.hide, closing.hide), m.id);

				// Keep line count by emitting newlines consumed by the arguments after the expansion
				for (int nl = 0; nl < newlines; nl++)
					stack.push_back({ T_NEWLINE, "\n", nullptr });

				for (int i = body.size() - 1; i >= 0; i--)
				{
					Tok b = body[i];
					b.hide = HideUnion(b.hide, hs);
					stack.push_back(std::move(b));
				}
			}

			return output;
		}

		bool Evaluate(const QVector<Tok>& exprToks, bool* ok)
		{
			QVector<Tok> expanded = Expand(exprToks, true);

			// Remove whitespace and comments for parsing
			QVector<Tok> clean;
			for (const Tok& t : expanded)
				if (t.type != T_WS && t.type != T_COMMENT && t.type != T_NEWLINE)
					clean.append(t);

			if (clean.isEmpty())
			{
				if (ok)
					*ok = false;
				return false;
			}

			ExprParser parser(clean);
			Value v = parser.Parse();
			if (ok)
				*ok = !parser.error;
			return v.AsBool();
		}

		static QString Join(const QVector<Tok>& toks)
		{
			QString s;
			for (const Tok& t : toks)
				s += t.text;
			return s;
		}

		// A range of tokens forming one line, excluding its terminating newline
		struct Span
		{
			const Tok* d;
			int n;
			int size() const { return n; }
			const Tok& operator[](int i) const { return d[i]; }
			QVector<Tok> Mid(int from) const
			{
				QVector<Tok> v;
				for (int i = from; i < n; i++)
					v.append(d[i]);
				return v;
			}
		};

		Result Process(const QString& source, bool properties)
		{
			Result result;
			QVector<Tok> toks = Tokenize(source, properties);

			QVector<QPair<int, int>> lines;
			{
				int start = 0;
				for (int t = 0; t < toks.size(); t++)
				{
					if (toks[t].type == T_NEWLINE)
					{
						lines.append({ start, t });
						start = t + 1;
					}
				}
				lines.append({ start, toks.size() });
			}

			QVector<CondState> conds;
			auto isActive = [&]() { return conds.isEmpty() || conds.last().active; };

			QVector<Tok> pending; // Text lines waiting for macro expansion
			pending.reserve(4096);
			QString out;
			out.reserve(source.size() + 1024);

			static const Tok newlineTok = { T_NEWLINE, QString("\n"), nullptr };

			auto flush = [&]()
			{
				if (pending.isEmpty())
					return;
				for (const Tok& t : Expand(pending))
					out += t.text;
				pending.clear();
			};

			static const QStringList propertyDirectives = {
				"define", "undef", "if", "ifdef", "ifndef", "elif", "else", "endif", "error", "warning", "pragma", "line", "include"
			};

			for (int l = 0; l < lines.size(); l++)
			{
				const Span line{ toks.constData() + lines[l].first, lines[l].second - lines[l].first };
				bool last = (l == lines.size() - 1);

				// Find first significant token
				int p = 0;
				while (p < line.size() && IsSpace(line[p]))
					p++;

				bool isDirective = (p < line.size() && line[p].type == T_PUNCT && line[p].text == "#");
				QString directive;
				int argStart = p + 1;

				if (isDirective)
				{
					int q = p + 1;
					while (q < line.size() && IsSpace(line[q]))
						q++;
					if (q < line.size() && (line[q].type == T_IDENT))
					{
						directive = line[q].text;
						argStart = q + 1;
					}
					else
						argStart = q;

					// In properties files, non-directive # lines are comments
					if (properties && !propertyDirectives.contains(directive))
					{
						if (!last)
							pending.append(newlineTok);
						continue;
					}
				}

				if (!isDirective)
				{
					if (isActive())
					{
						for (int t = 0; t < line.size(); t++)
							pending.append(line[t]);
						if (!last)
							pending.append(newlineTok);
					}
					else if (!last)
						pending.append(newlineTok);
					continue;
				}

				// Directive line: expand pending text first
				flush();

				QVector<Tok> args = line.Mid(argStart);

				if (directive == "if" || directive == "ifdef" || directive == "ifndef")
				{
					bool parent = isActive();
					bool value = false;
					if (parent)
					{
						if (directive == "if")
						{
							bool ok = true;
							value = Evaluate(args, &ok);
							if (!ok)
								result.errors.append("Could not evaluate #if " + Join(args).trimmed());
						}
						else
						{
							QVector<Tok> t = Trim(args);
							QString name = t.isEmpty() ? QString() : t[0].text;
							value = macros.contains(name);
							if (directive == "ifndef")
								value = !value;
						}
					}
					conds.append({ parent, parent && value, parent && value, false });
				}
				else if (directive == "elif")
				{
					if (conds.isEmpty())
						result.errors.append("#elif without #if");
					else
					{
						CondState& c = conds.last();
						if (!c.parentActive || c.taken)
							c.active = false;
						else
						{
							bool ok = true;
							bool value = Evaluate(args, &ok);
							if (!ok)
								result.errors.append("Could not evaluate #elif " + Join(args).trimmed());
							c.active = value;
							c.taken = value;
						}
					}
				}
				else if (directive == "else")
				{
					if (conds.isEmpty())
						result.errors.append("#else without #if");
					else
					{
						CondState& c = conds.last();
						c.active = c.parentActive && !c.taken;
						c.taken = true;
						c.seenElse = true;
					}
				}
				else if (directive == "endif")
				{
					if (conds.isEmpty())
						result.errors.append("#endif without #if");
					else
						conds.removeLast();
				}
				else if (isActive())
				{
					if (directive == "define")
						DefineFromTokens(args, result.errors);
					else if (directive == "undef")
					{
						QVector<Tok> t = Trim(args);
						if (!t.isEmpty())
							macros.remove(t[0].text);
					}
					else if (directive == "version")
					{
						if (result.version.isEmpty())
							result.version = "#version " + Join(Trim(args)).trimmed();
					}
					else if (directive == "extension")
						result.extensions.append("#extension " + Join(Trim(args)).trimmed());
					else if (directive == "error")
						result.errors.append("#error " + Join(Trim(args)).trimmed());
					else if (directive == "pragma" && !properties)
						out += Join(line.Mid(0));
					else if (directive == "include")
						result.errors.append("Unresolved #include " + Join(Trim(args)).trimmed());
					// #line, #warning and unknown directives are dropped
				}

				if (!last)
					out += '\n';
			}

			flush();

			if (!conds.isEmpty())
				result.errors.append("Unterminated #if");

			result.source = out;
			return result;
		}
	};

	Preprocessor::Preprocessor() : impl(new Impl) {}
	Preprocessor::~Preprocessor() {}

	void Preprocessor::Define(const QString& name, const QString& value)
	{
		QStringList errors;
		QVector<Tok> toks = Tokenize(name + " " + value, false);
		impl->DefineFromTokens(toks, errors);
	}

	void Preprocessor::Undefine(const QString& name)
	{
		impl->macros.remove(name);
	}

	bool Preprocessor::IsDefined(const QString& name) const
	{
		return impl->macros.contains(name);
	}

	Preprocessor::Result Preprocessor::ProcessGlsl(const QString& source)
	{
		return impl->Process(source, false);
	}

	QString Preprocessor::ProcessProperties(const QString& source)
	{
		// Trim lines and drop blank lines like Iris does
		QStringList lines = source.split(QRegularExpression("\r\n|\r|\n"));
		QStringList kept;
		for (QString& line : lines)
		{
			QString t = line.trimmed();
			if (!t.isEmpty())
				kept.append(t);
		}
		return impl->Process(kept.join('\n') + "\n", true).source;
	}

	bool Preprocessor::EvaluateCondition(const QString& expression, bool* ok)
	{
		return impl->Evaluate(Tokenize(expression, true), ok);
	}
}
