#include "SpTransformer.hpp"

#include <QRegularExpression>

namespace ShaderPacks
{
	const char* vertexAttribNames[ATTR_COUNT] = {
		"mi_Position", "mi_NormalPacked", "mi_ColorPacked", "mi_TexCoord", "mi_DataPacked",
		"mi_TangentPacked", "mi_BlockPacked", "mi_MidTexPacked", "mi_LightPacked", "mi_MidBlockPacked"
	};

	namespace
	{
		// ---------------------------------------------------------------------------------------------
		// Lexer

		enum TKind : uint8_t { K_IDENT, K_NUMBER, K_PUNCT, K_WS, K_COMMENT, K_NEWLINE, K_OTHER };

		struct GTok
		{
			TKind kind;
			QString text;
		};

		QVector<GTok> Lex(const QString& src)
		{
			QVector<GTok> toks;
			toks.reserve(src.size() / 3);
			const int n = src.size();
			int i = 0;
			while (i < n)
			{
				QChar c = src[i];
				if (c == '\n')
				{
					toks.append({ K_NEWLINE, "\n" });
					i++;
					continue;
				}
				if (c.isSpace())
				{
					int s = i;
					while (i < n && src[i].isSpace() && src[i] != '\n')
						i++;
					toks.append({ K_WS, src.mid(s, i - s) });
					continue;
				}
				if (c == '/' && i + 1 < n && src[i + 1] == '/')
				{
					int s = i;
					while (i < n && src[i] != '\n')
						i++;
					toks.append({ K_COMMENT, src.mid(s, i - s) });
					continue;
				}
				if (c == '/' && i + 1 < n && src[i + 1] == '*')
				{
					int s = i;
					int e = src.indexOf("*/", i + 2);
					i = (e < 0) ? n : e + 2;
					toks.append({ K_COMMENT, src.mid(s, i - s) });
					continue;
				}
				if (c.isLetter() || c == '_')
				{
					int s = i;
					while (i < n && (src[i].isLetterOrNumber() || src[i] == '_'))
						i++;
					toks.append({ K_IDENT, src.mid(s, i - s) });
					continue;
				}
				if (c.isDigit() || (c == '.' && i + 1 < n && src[i + 1].isDigit()))
				{
					int s = i;
					i++;
					while (i < n)
					{
						QChar d = src[i];
						if ((d == '+' || d == '-') && (src[i - 1] == 'e' || src[i - 1] == 'E') && !src.midRef(s, 2).startsWith("0x", Qt::CaseInsensitive))
						{
							i++;
							continue;
						}
						if (d.isLetterOrNumber() || d == '.' || d == '_')
						{
							i++;
							continue;
						}
						break;
					}
					toks.append({ K_NUMBER, src.mid(s, i - s) });
					continue;
				}

				static const char* two[] = { "<<=", ">>=", "<<", ">>", "<=", ">=", "==", "!=", "&&", "||", "^^", "++", "--",
											 "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=" };
				bool matched = false;
				for (const char* t : two)
				{
					int len = (int)strlen(t);
					if (src.midRef(i, len) == QLatin1String(t))
					{
						toks.append({ K_PUNCT, QString(t) });
						i += len;
						matched = true;
						break;
					}
				}
				if (matched)
					continue;

				toks.append({ QString("()[]{}.,;:?~!%^&*+-=|/<>#").contains(c) ? K_PUNCT : K_OTHER, QString(c) });
				i++;
			}
			return toks;
		}

		inline bool Insignificant(const GTok& t)
		{
			return t.kind == K_WS || t.kind == K_COMMENT || t.kind == K_NEWLINE || t.text.isEmpty();
		}

		// Returns whether a sampler type can sample a texture target (GL_TEXTURE_1D/2D/3D/RECTANGLE).
		bool SamplerMatchesTarget(const QString& type, unsigned int target)
		{
			QString base = type;
			if (base.startsWith('i') || base.startsWith('u'))
				base = base.mid(1);
			switch (target)
			{
				case 0x0DE0: return base == "sampler1D";
				case 0x0DE1: return base == "sampler2D";
				case 0x806F: return base == "sampler3D";
				case 0x84F5: return base == "sampler2DRect";
				default: return false;
			}
		}

		// ---------------------------------------------------------------------------------------------
		// Source model with analysis of global declarations

		struct Declarator
		{
			QString name;
			int nameTok;   // Token index of the name
			QString array; // Array suffix, e.g. "[3]"
			int start, end; // Token range of the declarator (name..end of initializer/array)
		};

		struct GlobalDecl
		{
			int start, end; // Token range including the semicolon
			QStringList qualifiers;
			QString layout; // Content of layout(...) if any
			QString type;
			QVector<Declarator> declarators;
			bool removed = false;

			bool Has(const QString& q) const { return qualifiers.contains(q); }
			bool IsInput() const { return Has("in") || Has("attribute") || Has("varying"); }
		};

		struct FunctionDef
		{
			QString name;
			int nameTok;
			int bodyOpen, bodyClose; // Token indices of { and }
		};

		static const QSet<QString>& QualifierWords()
		{
			static QSet<QString> q = { "in", "out", "inout", "attribute", "varying", "uniform", "buffer", "const", "flat", "smooth",
									   "noperspective", "centroid", "invariant", "highp", "mediump", "lowp", "precise", "patch",
									   "sample", "readonly", "writeonly", "coherent", "volatile", "restrict", "shared" };
			return q;
		}

		struct Source
		{
			QVector<GTok> toks;
			QVector<GlobalDecl> decls;
			QVector<FunctionDef> functions;
			QSet<QString> identifiers; // All identifiers in the source

			void Parse(const QString& body)
			{
				toks = Lex(body);
				Analyze();
			}

			int NextSig(int i) const
			{
				while (i < toks.size() && Insignificant(toks[i]))
					i++;
				return i;
			}

			int PrevSig(int i) const
			{
				while (i >= 0 && Insignificant(toks[i]))
					i--;
				return i;
			}

			bool IsCall(int i) const
			{
				int n = NextSig(i + 1);
				return n < toks.size() && toks[n].text == "(";
			}

			bool IsMember(int i) const
			{
				int p = PrevSig(i - 1);
				return p >= 0 && toks[p].text == ".";
			}

			void Analyze()
			{
				decls.clear();
				functions.clear();
				identifiers.clear();

				for (const GTok& t : toks)
					if (t.kind == K_IDENT)
						identifiers.insert(t.text);

				int depth = 0;
				int stmtStart = -1;
				for (int i = 0; i < toks.size(); i++)
				{
					const GTok& t = toks[i];
					if (Insignificant(t))
						continue;

					if (depth == 0 && stmtStart < 0)
						stmtStart = i;

					if (t.text == "{")
					{
						if (depth == 0)
						{
							// Function definition: <type> <name> ( ... ) {
							int close = PrevSig(i - 1);
							if (close >= 0 && toks[close].text == ")")
							{
								int open = MatchBackward(close);
								int nameTok = PrevSig(open - 1);
								if (nameTok >= 0 && toks[nameTok].kind == K_IDENT)
								{
									FunctionDef f;
									f.name = toks[nameTok].text;
									f.nameTok = nameTok;
									f.bodyOpen = i;
									f.bodyClose = MatchForward(i);
									functions.append(f);
									i = f.bodyClose;
									stmtStart = -1;
									continue;
								}
							}
						}
						depth++;
						continue;
					}
					if (t.text == "}")
					{
						depth--;
						continue;
					}
					if (t.text == ";" && depth == 0)
					{
						ParseDeclaration(stmtStart, i);
						stmtStart = -1;
					}
				}
			}

			int MatchForward(int open) const
			{
				QString o = toks[open].text, c = (o == "{") ? "}" : (o == "(") ? ")" : "]";
				int depth = 0;
				for (int i = open; i < toks.size(); i++)
				{
					if (toks[i].text == o)
						depth++;
					else if (toks[i].text == c && --depth == 0)
						return i;
				}
				return toks.size() - 1;
			}

			int MatchBackward(int close) const
			{
				QString c = toks[close].text, o = (c == "}") ? "{" : (c == ")") ? "(" : "[";
				int depth = 0;
				for (int i = close; i >= 0; i--)
				{
					if (toks[i].text == c)
						depth++;
					else if (toks[i].text == o && --depth == 0)
						return i;
				}
				return 0;
			}

			void ParseDeclaration(int start, int end)
			{
				if (start < 0)
					return;

				GlobalDecl d;
				d.start = start;
				d.end = end;

				int i = start;
				// Qualifiers and layout
				while (i < end)
				{
					i = NextSig(i);
					if (i >= end)
						return;
					const GTok& t = toks[i];
					if (t.text == "layout")
					{
						int open = NextSig(i + 1);
						if (open >= end || toks[open].text != "(")
							return;
						int close = MatchForward(open);
						QString content;
						for (int k = open + 1; k < close; k++)
							content += toks[k].text;
						d.layout = content.simplified();
						i = close + 1;
						continue;
					}
					if (t.kind == K_IDENT && QualifierWords().contains(t.text))
					{
						d.qualifiers.append(t.text);
						i++;
						continue;
					}
					break;
				}

				// Interface blocks and structs are skipped
				for (int k = i; k < end; k++)
					if (toks[k].text == "{" || toks[k].text == "(")
					{
						if (toks[k].text == "(" && k > i)
						{
							// Function prototype or constructor initializer, only skip prototypes
							int prevTok = PrevSig(k - 1);
							if (prevTok == NextSig(i + 1) || prevTok == i)
								return;
						}
						if (toks[k].text == "{")
							return;
					}

				if (i >= end || toks[i].kind != K_IDENT)
					return;
				d.type = toks[i].text;
				i++;

				// Type array suffix, e.g. "vec4[2] name"
				int n = NextSig(i);
				QString typeArray;
				while (n < end && toks[n].text == "[")
				{
					int close = MatchForward(n);
					for (int k = n; k <= close; k++)
						typeArray += toks[k].text;
					i = close + 1;
					n = NextSig(i);
				}
				d.type += typeArray;

				// Declarators
				while (i < end)
				{
					i = NextSig(i);
					if (i >= end || toks[i].kind != K_IDENT)
						break;

					Declarator dec;
					dec.name = toks[i].text;
					dec.nameTok = i;
					dec.start = i;
					i++;

					// Array suffix and initializer up to a top-level comma
					int depth = 0;
					bool inInit = false;
					while (i < end)
					{
						const QString& tx = toks[i].text;
						if (tx == "(" || tx == "[" || tx == "{")
							depth++;
						else if (tx == ")" || tx == "]" || tx == "}")
							depth--;
						else if (tx == "=" && depth == 0)
							inInit = true;
						else if (tx == "," && depth == 0)
							break;

						if (!inInit && !Insignificant(toks[i]))
							dec.array += tx;
						i++;
					}
					dec.end = i - 1;
					d.declarators.append(dec);

					if (i < end && toks[i].text == ",")
						i++;
				}

				if (!d.declarators.isEmpty())
					decls.append(d);
			}

			GlobalDecl* FindDecl(const QString& name, int* declaratorIndex = nullptr)
			{
				for (GlobalDecl& d : decls)
				{
					if (d.removed)
						continue;
					for (int k = 0; k < d.declarators.size(); k++)
						if (d.declarators[k].name == name)
						{
							if (declaratorIndex)
								*declaratorIndex = k;
							return &d;
						}
				}
				return nullptr;
			}

			// Removes a global declarator (the whole statement if it's the only declarator).
			void RemoveDeclarator(const QString& name)
			{
				int k;
				GlobalDecl* d = FindDecl(name, &k);
				if (!d)
					return;

				if (d->declarators.size() == 1)
				{
					for (int i = d->start; i <= d->end; i++)
						toks[i].text.clear();
					d->removed = true;
					return;
				}

				// Remove the declarator and an adjacent comma
				const Declarator& dec = d->declarators[k];
				for (int i = dec.start; i <= dec.end; i++)
					toks[i].text.clear();
				if (k > 0)
				{
					int comma = PrevSig(dec.start - 1);
					if (comma >= 0 && toks[comma].text == ",")
						toks[comma].text.clear();
				}
				else
				{
					int comma = NextSig(dec.end + 1);
					if (comma < toks.size() && toks[comma].text == ",")
						toks[comma].text.clear();
				}
				d->declarators.removeAt(k);
			}

			// Renames all identifier tokens with the given name.
			bool Rename(const QString& from, const QString& to, bool skipMembers = true)
			{
				if (!identifiers.contains(from))
					return false;
				for (GlobalDecl& d : decls)
					for (Declarator& dec : d.declarators)
						if (dec.name == from)
							dec.name = to;
				bool any = false;
				for (int i = 0; i < toks.size(); i++)
				{
					if (toks[i].kind == K_IDENT && toks[i].text == from && !(skipMembers && IsMember(i)))
					{
						toks[i].text = to;
						any = true;
					}
				}
				identifiers.insert(to);
				return any;
			}

			// Renames identifiers that are function calls.
			void RenameCall(const QString& from, const QString& to)
			{
				if (!identifiers.contains(from))
					return;
				for (int i = 0; i < toks.size(); i++)
					if (toks[i].kind == K_IDENT && toks[i].text == from && IsCall(i) && !IsMember(i))
						toks[i].text = to;
				identifiers.insert(to);
			}

			// Renames identifiers that aren't function calls.
			void RenameNonCall(const QString& from, const QString& to)
			{
				if (!identifiers.contains(from))
					return;
				for (int i = 0; i < toks.size(); i++)
					if (toks[i].kind == K_IDENT && toks[i].text == from && !IsCall(i) && !IsMember(i))
						toks[i].text = to;
				identifiers.insert(to);
			}

			// Replaces references to an identifier by an expression (wrapped in parentheses).
			void Replace(const QString& from, const QString& expr)
			{
				if (!identifiers.contains(from))
					return;
				static QRegularExpression identRe("[A-Za-z_][A-Za-z0-9_]*");
				auto it = identRe.globalMatch(expr);
				while (it.hasNext())
					identifiers.insert(it.next().captured(0));
				for (int i = 0; i < toks.size(); i++)
					if (toks[i].kind == K_IDENT && toks[i].text == from && !IsMember(i))
						toks[i].text = "(" + expr + ")";
			}

			// Wraps calls of a function: shadow2D(...) -> vec4(texture(...)).
			void WrapCall(const QString& from, const QString& inner, const QString& wrapper)
			{
				if (!identifiers.contains(from))
					return;
				for (int i = 0; i < toks.size(); i++)
				{
					if (toks[i].kind != K_IDENT || toks[i].text != from || IsMember(i) || !IsCall(i))
						continue;
					int open = NextSig(i + 1);
					int close = MatchForward(open);
					toks[i].text = wrapper + "(" + inner;
					toks[close].text = "))";
				}
			}

			// Replaces "name[<integer>]" patterns, the callback returns the replacement or a null string.
			void ReplaceIndexed(const QString& name, const std::function<QString(int index)>& replacement)
			{
				if (!identifiers.contains(name))
					return;
				for (int i = 0; i < toks.size(); i++)
				{
					if (toks[i].kind != K_IDENT || toks[i].text != name || IsMember(i))
						continue;
					int open = NextSig(i + 1);
					if (open >= toks.size() || toks[open].text != "[")
						continue;
					int idxTok = NextSig(open + 1);
					int close = NextSig(idxTok + 1);
					if (idxTok >= toks.size() || toks[idxTok].kind != K_NUMBER || close >= toks.size() || toks[close].text != "]")
						continue;
					bool ok = false;
					int index = toks[idxTok].text.toInt(&ok);
					if (!ok)
						continue;
					QString repl = replacement(index);
					if (repl.isNull())
						continue;
					toks[i].text = repl;
					for (int k = i + 1; k <= close; k++)
						toks[k].text.clear();
				}
			}

			bool Uses(const QString& name) const { return identifiers.contains(name); }

			void RecollectIdentifiers()
			{
				identifiers.clear();
				for (const GTok& t : toks)
					if (t.kind == K_IDENT && !t.text.isEmpty())
						identifiers.insert(t.text);
			}

			// Removes functions that are never referenced (like Iris), some packs rely on this
			// since unused functions may reference undeclared uniforms.
			void RemoveUnusedFunctions()
			{
				// Function prototypes at global scope
				QHash<QString, int> prototypes;
				for (const GlobalDecl& d : decls)
					Q_UNUSED(d);
				int depth = 0;
				for (int i = 0; i < toks.size(); i++)
				{
					const QString& t = toks[i].text;
					if (t == "{")
						depth++;
					else if (t == "}")
						depth--;
					else if (depth == 0 && toks[i].kind == K_IDENT && IsCall(i))
					{
						int prev = PrevSig(i - 1);
						if (prev >= 0 && (toks[prev].kind == K_IDENT || toks[prev].text == "]") && toks[prev].text != "return")
						{
							int open = NextSig(i + 1);
							int close = MatchForward(open);
							int after = NextSig(close + 1);
							if (after < toks.size() && toks[after].text == ";")
								prototypes[t]++;
						}
					}
				}

				QVector<bool> removed(functions.size(), false);
				bool changed = true;
				while (changed)
				{
					changed = false;
					QHash<QString, int> counts;
					for (const GTok& tk : toks)
						if (tk.kind == K_IDENT && !tk.text.isEmpty())
							counts[tk.text]++;

					QHash<QString, int> definitions;
					for (int f = 0; f < functions.size(); f++)
						if (!removed[f])
							definitions[functions[f].name]++;

					for (int f = 0; f < functions.size(); f++)
					{
						const FunctionDef& fn = functions[f];
						if (removed[f] || fn.name == "main")
							continue;
						if (counts.value(fn.name) > definitions.value(fn.name) + prototypes.value(fn.name))
							continue;

						// Remove from the end of the previous statement to the closing brace
						int start = fn.nameTok;
						while (start > 0)
						{
							int prev = PrevSig(start - 1);
							if (prev < 0 || toks[prev].text == ";" || toks[prev].text == "}")
								break;
							start = prev;
						}
						for (int k = start; k <= fn.bodyClose; k++)
							toks[k].text.clear();
						removed[f] = true;
						changed = true;
					}
				}

				QVector<FunctionDef> kept;
				for (int f = 0; f < functions.size(); f++)
					if (!removed[f])
						kept.append(functions[f]);
				functions = kept;
				RecollectIdentifiers();
			}

			const FunctionDef* FindFunction(const QString& name) const
			{
				for (const FunctionDef& f : functions)
					if (f.name == name)
						return &f;
				return nullptr;
			}

			QString Text() const
			{
				QString s;
				s.reserve(toks.size() * 4);
				for (const GTok& t : toks)
					s += t.text;
				return s;
			}
		};

		// ---------------------------------------------------------------------------------------------
		// Helpers

		int TypeComponents(const QString& type)
		{
			if (type == "float" || type == "int" || type == "uint" || type == "bool")
				return 1;
			if (type.endsWith('2'))
				return 2;
			if (type.endsWith('3'))
				return 3;
			if (type.endsWith('4'))
				return 4;
			return 0;
		}

		bool TypeIsInt(const QString& type)
		{
			return type == "int" || type.startsWith("ivec");
		}

		bool TypeIsUint(const QString& type)
		{
			return type == "uint" || type.startsWith("uvec");
		}

		// Converts a vec4 expression to the given scalar/vector type.
		QString ConvertVec4(const QString& expr, const QString& type)
		{
			int n = TypeComponents(type);
			static const char* swz[] = { "", ".x", ".xy", ".xyz", "" };
			QString e = "(" + expr + ")" + swz[qBound(0, n, 4)];
			if (type == "vec4")
				return expr;
			return type + "(" + e + ")";
		}

		struct StageInfo
		{
			Source src;
			Stage stage;
			int version = 330;
			QString profile;
			bool core = false;
			QStringList header;		// Declarations inserted before the source
			QStringList functions;	// Helper functions inserted after declarations
			QStringList prologue;	// Statements run before the original main
			QStringList epilogue;	// Statements run after the original main
			bool wrapMain = false;
			QSet<QString> declared; // Names declared through the header
		};

		const QString lightmapMatrix =
			"mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0))";

		const QString compositeProjection =
			"mat4(vec4(2.0, 0.0, 0.0, 0.0), vec4(0.0, 2.0, 0.0, 0.0), vec4(0.0), vec4(-1.0, -1.0, 0.0, 1.0))";

		// Adds a uniform declaration if the source doesn't declare it.
		void AddUniform(StageInfo& s, const QString& type, const QString& name)
		{
			if (s.src.FindDecl(name) || s.declared.contains(name))
				return;
			s.declared.insert(name);
			s.header.append("uniform " + type + " " + name + ";");
		}

		void ParseVersion(StageInfo& s, const QString& versionLine)
		{
			QStringList parts = versionLine.simplified().split(' ');
			s.version = parts.value(1, "110").toInt();
			s.profile = parts.value(2).toLower();
			if (s.version == 0)
				s.version = 110;
		}

		// Provides an input as a global variable with the declared type of a pack attribute,
		// initialized from a vec4 expression in the prologue.
		void ProvideAttribute(StageInfo& s, const QString& name, const QString& vec4Expr, const QString& defaultType = QString())
		{
			int k;
			GlobalDecl* d = s.src.FindDecl(name, &k);
			QString type;
			if (d && d->IsInput())
			{
				type = d->type;
				s.src.RemoveDeclarator(name);
			}
			else if (!d && !defaultType.isEmpty() && s.src.Uses(name))
				type = defaultType; // Implicitly available input (core profile attributes)
			else
				return;

			s.header.append(type + " " + name + ";");

			int n = qBound(1, TypeComponents(type), 4);
			static const char* swz[] = { "", ".x", ".xy", ".xyz", "" };
			QString e = (n == 4) ? "(" + vec4Expr + ")" : "(" + vec4Expr + ")" + swz[n];

			QString value;
			if (TypeIsInt(type))
				value = (n == 1 ? QString("int") : type) + "(" + e + ")";
			else if (TypeIsUint(type))
				value = (n == 1 ? QString("uint") : type) + "(" + e + ")";
			else
				value = (n == 1 ? QString("float") : type) + "(" + e + ")";
			s.prologue.append(name + " = " + value + ";");
		}

		// ---------------------------------------------------------------------------------------------
		// Common transformations (CommonTransformer in Iris)

		void TransformCommon(StageInfo& s, const TransformParams& params)
		{
			Source& src = s.src;

			// Fog
			if (src.Uses("gl_FogFragCoord"))
			{
				src.Rename("gl_FogFragCoord", "iris_FogFragCoord");
				if (s.stage == STAGE_VERTEX)
				{
					s.header.append("out float iris_FogFragCoord;");
					s.prologue.append("iris_FogFragCoord = 0.0;");
				}
				else if (s.stage == STAGE_FRAGMENT)
					s.header.append("in float iris_FogFragCoord;");
				else if (s.stage == STAGE_GEOMETRY)
					s.header.append("float iris_FogFragCoord;");
			}

			if (src.Uses("gl_Fog"))
			{
				src.Rename("gl_Fog", "irisInt_Fog");
				AddUniform(s, "float", "iris_FogDensity");
				AddUniform(s, "float", "iris_FogStart");
				AddUniform(s, "float", "iris_FogEnd");
				AddUniform(s, "vec4", "iris_FogColor");
				s.header.append("struct iris_FogParameters { vec4 color; float density; float start; float end; float scale; };");
				s.header.append("iris_FogParameters irisInt_Fog = iris_FogParameters(vec4(0.0), 0.0, 0.0, 1.0, 1.0);");
				s.prologue.append("irisInt_Fog = iris_FogParameters(iris_FogColor, iris_FogDensity, iris_FogStart, iris_FogEnd, 1.0 / max(iris_FogEnd - iris_FogStart, 0.0001));");
			}

			if (s.stage == STAGE_VERTEX)
			{
				// Legacy color/texcoord outputs feed the fragment inputs
				if (src.Uses("gl_FrontColor"))
				{
					src.Rename("gl_FrontColor", "irs_Color");
					s.header.append("out vec4 irs_Color;");
				}
				if (src.Uses("gl_BackColor"))
				{
					src.Rename("gl_BackColor", "iris_BackColor");
					s.header.append("vec4 iris_BackColor;");
				}
				if (src.Uses("gl_TexCoord"))
				{
					src.Rename("gl_TexCoord", "irs_texCoords");
					s.header.append("out vec4 irs_texCoords[8];");
				}
				if (src.Uses("gl_FrontSecondaryColor"))
				{
					src.Rename("gl_FrontSecondaryColor", "iris_FrontSecondaryColor");
					s.header.append("vec4 iris_FrontSecondaryColor;");
				}
			}

			if (s.stage == STAGE_FRAGMENT)
			{
				if (src.Uses("gl_TexCoord"))
				{
					src.Rename("gl_TexCoord", "irs_texCoords");
					s.header.append("in vec4 irs_texCoords[8];");
				}
				if (src.Uses("gl_Color"))
				{
					src.Rename("gl_Color", "irs_Color");
					s.header.append("in vec4 irs_Color;");
				}
			}

			// Storage qualifiers
			if (s.stage == STAGE_VERTEX || s.stage == STAGE_FRAGMENT)
			{
				for (GTok& t : src.toks)
				{
					if (t.kind != K_IDENT)
						continue;
					if (t.text == "attribute")
						t.text = "in";
					else if (t.text == "varying")
						t.text = (s.stage == STAGE_VERTEX) ? "out" : "in";
				}
				for (GlobalDecl& d : src.decls)
					for (QString& q : d.qualifiers)
					{
						if (q == "attribute")
							q = "in";
						else if (q == "varying")
							q = (s.stage == STAGE_VERTEX) ? "out" : "in";
					}
			}

			// Samplers named "texture" or "gcolor" become "gtexture"
			bool renamedSampler = false;
			for (const QString& name : { "gcolor", "texture" })
			{
				int k;
				GlobalDecl* d = src.FindDecl(name, &k);
				if (!d || !d->Has("uniform") || !d->type.startsWith("sampler"))
					continue;

				if (renamedSampler || src.FindDecl("gtexture"))
				{
					// Only keep one declaration
					src.RemoveDeclarator(name);
					src.RenameNonCall(name, "gtexture");
				}
				else
				{
					src.RenameNonCall(name, "gtexture");
					renamedSampler = true;
				}
			}

			// Legacy texture functions
			static const QPair<const char*, const char*> renames[] = {
				{ "texture2D", "texture" }, { "texture3D", "texture" }, { "texture1D", "texture" }, { "textureCube", "texture" },
				{ "texture2DLod", "textureLod" }, { "texture3DLod", "textureLod" }, { "texture1DLod", "textureLod" },
				{ "textureCubeLod", "textureLod" }, { "texture2DProj", "textureProj" }, { "texture3DProj", "textureProj" },
				{ "texture2DGrad", "textureGrad" }, { "texture2DGradARB", "textureGrad" }, { "texture3DGrad", "textureGrad" },
				{ "texture2DLodEXT", "textureLod" }, { "texture2DGradEXT", "textureGrad" }, { "texelFetch2D", "texelFetch" },
				{ "texelFetch3D", "texelFetch" }, { "textureSize2D", "textureSize" }, { "texture2DRect", "texture" },
			};
			for (const auto& r : renames)
				src.RenameCall(r.first, r.second);

			src.WrapCall("shadow2D", "texture", "vec4");
			src.WrapCall("shadow2DLod", "textureLod", "vec4");
			src.WrapCall("shadow2DProj", "textureProj", "vec4");

			// Reserved words used as identifiers in old GLSL versions
			src.RenameNonCall("texture", "iris_renamed_texture");
			if (s.version < 400)
				src.RenameNonCall("sample", "iris_renamed_sample");
		}

		// Fragment outputs: gl_FragData[i]/gl_FragColor -> layout(location = i) out vec4 iris_FragDatai
		void TransformFragmentOutputs(StageInfo& s, TransformResult& result)
		{
			Source& src = s.src;
			QSet<int> indices;

			if (src.Uses("gl_FragColor"))
			{
				src.Rename("gl_FragColor", "iris_FragData0");
				indices.insert(0);
			}

			bool dynamicIndex = false;
			src.ReplaceIndexed("gl_FragData", [&](int index)
			{
				indices.insert(index);
				return "iris_FragData" + QString::number(index);
			});

			// Remaining gl_FragData uses have a non-constant index
			for (const GTok& t : src.toks)
				if (t.kind == K_IDENT && t.text == "gl_FragData")
					dynamicIndex = true;

			if (dynamicIndex)
			{
				src.Rename("gl_FragData", "iris_FragData");
				s.header.append("layout(location = 0) out vec4 iris_FragData[8];");
				for (int i = 0; i < 8; i++)
					result.fragmentOutputs.append(i);
				return;
			}

			QList<int> sorted = indices.values();
			std::sort(sorted.begin(), sorted.end());
			for (int i : sorted)
			{
				s.header.append(QString("layout(location = %1) out vec4 iris_FragData%1;").arg(i));
				result.fragmentOutputs.append(i);
			}

			// Explicit outputs: assign locations to outputs without layouts
			QSet<int> used = indices;
			QVector<GlobalDecl*> unassigned;
			for (GlobalDecl& d : src.decls)
			{
				if (d.removed || !d.Has("out"))
					continue;

				QRegularExpressionMatch m = QRegularExpression("location\\s*=\\s*(\\d+)").match(d.layout);
				if (m.hasMatch())
				{
					int loc = m.captured(1).toInt();
					used.insert(loc);
					result.fragmentOutputs.append(loc);
				}
				else
					unassigned.append(&d);
			}

			int nextFree = 0;
			for (GlobalDecl* d : unassigned)
			{
				QString text;
				QStringList quals = d->qualifiers;
				for (const Declarator& dec : d->declarators)
				{
					int loc;
					QRegularExpressionMatch nm = QRegularExpression("^outColor(\\d)$").match(dec.name);
					if (nm.hasMatch())
						loc = nm.captured(1).toInt();
					else
					{
						while (used.contains(nextFree))
							nextFree++;
						loc = nextFree;
					}
					used.insert(loc);
					result.fragmentOutputs.append(loc);
					text += QString("layout(location = %1) %2 %3 %4%5; ").arg(loc).arg(quals.join(' '), d->type, dec.name, dec.array);
				}
				for (int k = d->start; k <= d->end; k++)
					src.toks[k].text.clear();
				src.toks[d->start].text = text;
			}
		}

		// ---------------------------------------------------------------------------------------------
		// Geometry programs (gbuffers_*, shadow*)

		void TransformGeometry(StageInfo& s, const TransformParams& params)
		{
			Source& src = s.src;

			// Iris uniform with the program's alpha test reference
			if (src.Uses("alphaTestRef"))
			{
				src.Rename("alphaTestRef", "mi_AlphaTestRef");
				AddUniform(s, "float", "mi_AlphaTestRef");
			}

			// Chunk fade-in (IRIS_FEATURE_FADE_VARIABLE), geometry is always fully faded in
			if (s.stage == STAGE_VERTEX && src.Uses("mc_chunkFade") && !src.FindDecl("mc_chunkFade"))
				s.header.append(params.programName.startsWith("shadow") ? "const float mc_chunkFade = -1.0;" : "const float mc_chunkFade = 1.0;");

			// Matrices (all stages)
			if (s.core)
			{
				static const QPair<const char*, const char*> coreUniforms[] = {
					{ "modelViewMatrix", "mi_ModelViewMat" }, { "modelViewMatrixInverse", "mi_ModelViewMatInverse" },
					{ "projectionMatrix", "mi_ProjMat" }, { "projectionMatrixInverse", "mi_ProjMatInverse" },
					{ "normalMatrix", "mi_NormalMat" }, { "textureMatrix", "mat4(1.0)" }, { "chunkOffset", "vec3(0.0)" },
				};
				for (const auto& u : coreUniforms)
				{
					if (!src.Uses(u.first))
						continue;
					src.RemoveDeclarator(u.first);
					src.Replace(u.first, u.second);
				}
			}

			src.ReplaceIndexed("gl_TextureMatrix", [](int index) -> QString
			{
				if (index == 0)
					return "mat4(1.0)";
				if (index == 1 || index == 2)
					return lightmapMatrix;
				return "mat4(1.0)";
			});

			src.Replace("gl_ModelViewProjectionMatrix", "mi_ProjMat * mi_ModelViewMat");
			src.Rename("gl_ModelViewMatrix", "mi_ModelViewMat");
			src.Rename("gl_ModelViewMatrixInverse", "mi_ModelViewMatInverse");
			src.Rename("gl_ProjectionMatrix", "mi_ProjMat");
			src.Rename("gl_ProjectionMatrixInverse", "mi_ProjMatInverse");
			src.Rename("gl_NormalMatrix", "mi_NormalMat");

			for (const QString& u : { "mi_ModelViewMat", "mi_ModelViewMatInverse", "mi_ProjMat", "mi_ProjMatInverse" })
				if (src.Uses(u))
					AddUniform(s, "mat4", u);
			if (src.Uses("mi_NormalMat"))
				AddUniform(s, "mat3", "mi_NormalMat");

			if (s.stage != STAGE_VERTEX)
				return;

			// Vertex inputs from the host vertex format
			for (int a = 0; a < ATTR_COUNT; a++)
			{
				static const char* types[ATTR_COUNT] = { "vec3", "uint", "uint", "vec2", "uint", "uint", "uint", "uint", "uint", "uint" };
				s.header.append(QString("layout(location = %1) in %2 %3;").arg(a).arg(types[a]).arg(vertexAttribNames[a]));
			}

			AddUniform(s, "mat4", "mi_ModelMat");
			AddUniform(s, "mat3", "mi_ModelNormalMat");
			AddUniform(s, "vec4", "mi_ColorModulator");
			AddUniform(s, "vec4", "mi_UvRect");
			AddUniform(s, "float", "mi_AmbientOcclusionLevel");
			AddUniform(s, "isampler2D", "mi_BlockOffsets");
			AddUniform(s, "isampler2D", "mi_BlockIds");

			s.header.append("vec4 mi_glVertex; vec3 mi_glNormal; vec4 mi_glColor; vec2 mi_UV0; vec2 mi_UV2; vec4 mi_glTangent;");
			s.header.append("vec4 mi_Entity; vec2 mi_MidTexCoord; vec4 mi_MidBlock;");

			s.functions.append(
				"vec3 mi_UnpackDir(uint p) {\n"
				"	return vec3(float(p & 255u), float((p >> 8u) & 255u), float((p >> 16u) & 255u)) / 127.5 - vec3(1.0);\n"
				"}\n"
				"void mi_Unpack() {\n"
				"	mi_glVertex = vec4((mi_ModelMat * vec4(mi_Position, 1.0)).xyz, 1.0);\n"
				"	vec3 n = mi_UnpackDir(mi_NormalPacked);\n"
				"	mi_glNormal = normalize(mi_ModelNormalMat * (dot(n, n) > 0.0 ? n : vec3(0.0, 0.0, 1.0)));\n"
				"	vec3 t = mi_UnpackDir(mi_TangentPacked);\n"
				"	mi_glTangent = vec4(dot(t, t) > 0.01 ? normalize(mat3(mi_ModelMat) * t) : vec3(1.0, 0.0, 0.0), 1.0);\n"
				"	vec4 c = vec4(float(mi_ColorPacked & 255u), float((mi_ColorPacked >> 8u) & 255u), float((mi_ColorPacked >> 16u) & 255u), float((mi_ColorPacked >> 24u) & 255u)) / 255.0;\n"
				"	float ao = float((mi_LightPacked >> 16u) & 255u) / 255.0;\n"
				"	c.rgb *= mix(1.0, ao, mi_AmbientOcclusionLevel);\n"
				"	mi_glColor = c * mi_ColorModulator;\n"
				"	mi_UV0 = mi_UvRect.xy + mi_TexCoord * mi_UvRect.zw;\n"
				"	mi_UV2 = vec2(float(mi_LightPacked & 255u), float((mi_LightPacked >> 8u) & 255u));\n"
				"	vec2 mid = (mi_MidTexPacked == 0xFFFFFFFFu) ? mi_TexCoord : vec2(float(mi_MidTexPacked & 65535u), float(mi_MidTexPacked >> 16u)) / 65535.0;\n"
				"	mi_MidTexCoord = mi_UvRect.xy + mid * mi_UvRect.zw;\n"
				"	ivec3 mb = ivec3(int(mi_MidBlockPacked << 24u) >> 24, int(mi_MidBlockPacked << 16u) >> 24, int(mi_MidBlockPacked << 8u) >> 24);\n"
				"	vec3 mbw = mat3(mi_ModelMat) * vec3(mb) * 16.0;\n"
				"	mi_MidBlock = vec4(mbw, float(mi_MidBlockPacked >> 24u));\n"
				"	mi_Entity = vec4(0.0, 0.0, 0.0, 1.0);\n"
				"	if (mi_BlockPacked != 0u) {\n"
				"		int blockId = int(mi_BlockPacked & 4095u);\n"
				"		int state = int(mi_BlockPacked >> 12u);\n"
				"		int offset = texelFetch(mi_BlockOffsets, ivec2(blockId & 1023, blockId >> 10), 0).x;\n"
				"		int id = -1;\n"
				"		if (offset >= 0) {\n"
				"			int index = offset + state;\n"
				"			id = texelFetch(mi_BlockIds, ivec2(index & 4095, index >> 12), 0).x;\n"
				"		}\n"
				"		mi_Entity = vec4(float(id), float((mi_LightPacked >> 24u) & 1u), 0.0, 1.0);\n"
				"	}\n"
				"}\n");
			s.prologue.prepend("mi_Unpack();");

			// Core profile attributes
			if (s.core)
			{
				ProvideAttribute(s, "vaPosition", "mi_glVertex", "vec3");
				ProvideAttribute(s, "vaColor", "mi_glColor", "vec4");
				ProvideAttribute(s, "vaUV0", "vec4(mi_UV0, 0.0, 1.0)", "vec2");
				ProvideAttribute(s, "vaUV1", "vec4(0.0, 10.0, 0.0, 1.0)", "ivec2");
				ProvideAttribute(s, "vaUV2", "vec4(mi_UV2, 0.0, 1.0)", "ivec2");
				ProvideAttribute(s, "vaNormal", "vec4(mi_glNormal, 0.0)", "vec3");
			}

			// Iris/OptiFine attributes
			ProvideAttribute(s, "mc_Entity", "mi_Entity");
			ProvideAttribute(s, "mc_midTexCoord", "vec4(mi_MidTexCoord, 0.0, 1.0)");
			ProvideAttribute(s, "at_tangent", "mi_glTangent");
			ProvideAttribute(s, "at_midBlock", "mi_MidBlock");
			ProvideAttribute(s, "at_velocity", "vec4(0.0)");
			ProvideAttribute(s, "iris_Entity", "mi_Entity");

			if (src.Uses("gl_MultiTexCoord3") && !src.FindDecl("mc_midTexCoord"))
				src.Replace("gl_MultiTexCoord3", "vec4(mi_MidTexCoord, 0.0, 1.0)");

			src.Rename("gl_Vertex", "mi_glVertex");
			src.Rename("gl_Normal", "mi_glNormal");
			src.Rename("gl_Color", "mi_glColor");
			src.Replace("gl_MultiTexCoord0", "vec4(mi_UV0, 0.0, 1.0)");
			src.Replace("gl_MultiTexCoord1", "vec4(mi_UV2, 0.0, 1.0)");
			src.Replace("gl_MultiTexCoord2", "vec4(mi_UV2, 0.0, 1.0)");
			for (int i = 3; i < 8; i++)
				src.Replace("gl_MultiTexCoord" + QString::number(i), "vec4(0.0, 0.0, 0.0, 1.0)");
			src.Replace("gl_SecondaryColor", "vec4(0.0)");

			if (src.Uses("ftransform"))
			{
				src.RenameCall("ftransform", "iris_ftransform");
				AddUniform(s, "mat4", "mi_ModelViewMat");
				AddUniform(s, "mat4", "mi_ProjMat");
				s.functions.append("vec4 iris_ftransform() { return mi_ProjMat * (mi_ModelViewMat * mi_glVertex); }");
			}
		}

		// ---------------------------------------------------------------------------------------------
		// Composite programs (fullscreen passes)

		void TransformComposite(StageInfo& s)
		{
			Source& src = s.src;

			if (s.core)
			{
				const QPair<QString, QString> coreUniforms[] = {
					{ "modelViewMatrix", "mat4(1.0)" }, { "projectionMatrix", compositeProjection },
					{ "modelViewMatrixInverse", "mat4(1.0)" }, { "projectionMatrixInverse", "inverse(" + compositeProjection + ")" },
					{ "textureMatrix", "mat4(1.0)" }, { "normalMatrix", "mat3(1.0)" },
				};
				for (const auto& u : coreUniforms)
				{
					if (!src.Uses(u.first))
						continue;
					src.RemoveDeclarator(u.first);
					src.Replace(u.first, u.second);
				}
			}

			src.ReplaceIndexed("gl_TextureMatrix", [](int) -> QString { return "mat4(1.0)"; });
			src.Replace("gl_ModelViewProjectionMatrix", compositeProjection);
			src.Replace("gl_ModelViewMatrix", "mat4(1.0)");
			src.Replace("gl_ModelViewMatrixInverse", "mat4(1.0)");
			src.Replace("gl_ProjectionMatrix", compositeProjection);
			src.Replace("gl_ProjectionMatrixInverse", "inverse(" + compositeProjection + ")");
			src.Replace("gl_NormalMatrix", "mat3(1.0)");

			if (s.stage == STAGE_VERTEX)
			{
				s.header.append(QString("layout(location = %1) in vec3 mi_Position;").arg(ATTR_POSITION));
				s.header.append(QString("layout(location = %1) in vec2 mi_TexCoord;").arg(ATTR_UV));

				if (s.core)
				{
					ProvideAttribute(s, "vaPosition", "vec4(mi_Position, 1.0)", "vec3");
					ProvideAttribute(s, "vaUV0", "vec4(mi_TexCoord, 0.0, 1.0)", "vec2");
					ProvideAttribute(s, "vaColor", "vec4(1.0)", "vec4");
					ProvideAttribute(s, "vaNormal", "vec4(0.0, 0.0, 1.0, 0.0)", "vec3");
				}

				src.Replace("gl_Vertex", "vec4(mi_Position, 1.0)");
				src.Replace("gl_MultiTexCoord0", "vec4(mi_TexCoord, 0.0, 1.0)");
				for (int i = 1; i < 8; i++)
					src.Replace("gl_MultiTexCoord" + QString::number(i), "vec4(0.0, 0.0, 0.0, 1.0)");
				src.Replace("gl_Color", "vec4(1.0)");
				src.Replace("gl_Normal", "vec3(0.0, 0.0, 1.0)");

				if (src.Uses("ftransform"))
				{
					src.RenameCall("ftransform", "iris_ftransform");
					s.functions.append("vec4 iris_ftransform() { return " + compositeProjection + " * vec4(mi_Position, 1.0); }");
				}
			}
			else
				src.Replace("gl_Color", "vec4(1.0)");
		}

		// Renames the main function so a wrapper can run prologue/epilogue code.
		void WrapMain(StageInfo& s)
		{
			if (s.prologue.isEmpty() && s.epilogue.isEmpty())
				return;

			Source& src = s.src;
			bool found = false;
			for (int i = 0; i < src.toks.size(); i++)
			{
				if (src.toks[i].kind == K_IDENT && src.toks[i].text == "main" && src.IsCall(i))
				{
					int p = src.PrevSig(i - 1);
					if (p >= 0 && src.toks[p].text == "void")
					{
						src.toks[i].text = "mi_PackMain";
						found = true;
					}
				}
			}
			s.wrapMain = found;
		}

		QString Assemble(StageInfo& s, const QStringList& extensions)
		{
			int version = qMax(s.version, 330);
			if (s.stage == STAGE_COMPUTE)
				version = qMax(version, 430);
			if (s.stage == STAGE_TESS_CONTROL || s.stage == STAGE_TESS_EVAL)
				version = qMax(version, 400);

			QString out = QString("#version %1 core\n").arg(version);
			for (QString ext : extensions)
			{
				ext.replace(QRegularExpression(":\\s*require"), ": enable");
				out += ext + "\n";
			}
			out += "#define MI_TRANSFORMED 1\n";
			for (const QString& h : s.header)
				out += h + "\n";

			QString body = s.src.Text();

			// Helper functions must come after the pack's declarations they may reference, but before
			// main. Insert them before the first function definition of the pack.
			QString functions = s.functions.join("\n");
			if (!functions.isEmpty())
			{
				int insertTok = -1;
				if (!s.src.functions.isEmpty())
				{
					// Find the start of the first function's return type
					const FunctionDef& f = s.src.functions.first();
					int typeTok = s.src.PrevSig(f.nameTok - 1);
					while (typeTok > 0)
					{
						int prev = s.src.PrevSig(typeTok - 1);
						if (prev < 0 || s.src.toks[prev].text == ";" || s.src.toks[prev].text == "}")
							break;
						typeTok = prev;
					}
					insertTok = typeTok;
				}

				if (insertTok >= 0)
				{
					QString before, after;
					for (int i = 0; i < s.src.toks.size(); i++)
						(i < insertTok ? before : after) += s.src.toks[i].text;
					body = before + "\n" + functions + "\n" + after;
				}
				else
					body = functions + "\n" + body;
			}

			out += body;

			if (s.wrapMain)
			{
				out += "\nvoid main() {\n";
				for (const QString& p : s.prologue)
					out += "\t" + p + "\n";
				out += "\tmi_PackMain();\n";
				for (const QString& e : s.epilogue)
					out += "\t" + e + "\n";
				out += "}\n";
			}
			return out;
		}

		// Adds missing vertex outputs for fragment inputs (CompatibilityTransformer.transformGrouped)
		void LinkStages(StageInfo& prev, StageInfo& next, TransformResult& result)
		{
			if (prev.stage == STAGE_GEOMETRY || next.stage == STAGE_GEOMETRY)
				return; // Geometry shader interfaces use arrays, keep them as they are

			QSet<QString> outs;
			for (const GlobalDecl& d : prev.src.decls)
				if (!d.removed && (d.Has("out") || d.Has("varying")))
					for (const Declarator& dec : d.declarators)
					{
						outs.insert(dec.name);

						// Vertex outputs some packs never write: most drivers then pass zeros,
						// so initialize them to keep results consistent between drivers
						if (prev.stage == STAGE_VERTEX && dec.array.isEmpty() && !d.Has("const") &&
							!d.type.startsWith("mat") && TypeComponents(d.type) > 0)
							prev.prologue.append(dec.name + " = " + (d.type == "bool" ? QString("false") : d.type + "(0)") + ";");
					}
			for (const QString& h : prev.header)
			{
				QRegularExpressionMatch m = QRegularExpression("\\bout\\s+\\w+\\s+(\\w+)").match(h);
				if (m.hasMatch())
					outs.insert(m.captured(1));
			}

			// Inputs added by the transformer (e.g. irs_Color)
			for (const QString& h : next.header)
			{
				QRegularExpressionMatch m = QRegularExpression("^(flat\\s+)?in\\s+(\\w+)\\s+(\\w+)(\\[\\d+\\])?;").match(h);
				if (!m.hasMatch() || outs.contains(m.captured(3)))
					continue;
				prev.header.append(m.captured(1) + "out " + m.captured(2) + " " + m.captured(3) + m.captured(4) + ";");
				if (m.captured(4).isEmpty())
					prev.prologue.append(m.captured(3) + " = " + m.captured(2) + "(0);");
				outs.insert(m.captured(3));
			}

			for (const GlobalDecl& d : next.src.decls)
			{
				if (d.removed || !(d.Has("in") || d.Has("varying")))
					continue;
				for (const Declarator& dec : d.declarators)
				{
					if (outs.contains(dec.name))
						continue;

					QStringList quals;
					for (const QString& q : d.qualifiers)
						if (q != "in" && q != "varying")
							quals.append(q);
					quals.append("out");
					prev.header.append(quals.join(' ') + " " + d.type + " " + dec.name + dec.array + ";");

					if (dec.array.isEmpty())
					{
						QString zero = d.type + "(0)";
						if (d.type == "bool")
							zero = "false";
						if (!d.type.startsWith("mat") && !d.type.startsWith("bool") && TypeComponents(d.type) > 0)
							prev.prologue.append(dec.name + " = " + zero + ";");
					}
					result.warnings.append("Added missing vertex output " + dec.name);
				}
			}
		}
	}

	TransformResult TransformProgram(const ProgramSource& program, const TransformParams& params)
	{
		TransformResult result;
		StageInfo stages[STAGE_COUNT];
		bool present[STAGE_COUNT] = {};

		for (int st = 0; st < STAGE_COUNT; st++)
		{
			const StageSource& source = program.stages[st];
			if (!source.IsValid())
				continue;
			if (params.kind == ProgramKind::Compute && st != STAGE_COMPUTE)
				continue;
			if (params.kind != ProgramKind::Compute && st == STAGE_COMPUTE)
				continue;

			present[st] = true;
			StageInfo& s = stages[st];
			s.stage = (Stage)st;
			ParseVersion(s, source.version.isEmpty() ? "#version 110" : source.version);
			s.core = (s.profile == "core") || (s.version >= 150 && s.profile.isEmpty());
			// Iris always uses the core profile transformation for lines
			if (params.kind == ProgramKind::Geometry && params.programName == "gbuffers_line")
				s.core = true;
			s.src.Parse(source.body);
			s.src.RemoveUnusedFunctions();

			// Raw custom textures replace uniform samplers of the same name and type
			for (const SamplerPatchSpec& patch : params.samplerPatches)
			{
				GlobalDecl* d = s.src.FindDecl(patch.sampler);
				if (d && d->Has("uniform") && SamplerMatchesTarget(d->type, patch.target))
					s.src.Rename(patch.sampler, patch.newName);
			}

			// Internal names may not be used by packs
			for (const QString& id : s.src.identifiers)
				if (id.startsWith("mi_"))
				{
					result.warnings.append("Shader uses reserved identifier " + id);
					break;
				}

			TransformCommon(s, params);

			if (params.kind == ProgramKind::Geometry)
				TransformGeometry(s, params);
			else if (params.kind == ProgramKind::Composite)
				TransformComposite(s);

			if (st == STAGE_FRAGMENT)
			{
				TransformFragmentOutputs(s, result);

				// Alpha test for compatibility profile gbuffers programs
				if (params.alphaTest && params.kind == ProgramKind::Geometry && s.src.Uses("iris_FragData0"))
				{
					AddUniform(s, "float", "mi_AlphaTestRef");
					s.epilogue.append("if (!(iris_FragData0.a > mi_AlphaTestRef)) discard;");
				}
			}
		}

		// Link stage interfaces
		int order[] = { STAGE_VERTEX, STAGE_TESS_CONTROL, STAGE_TESS_EVAL, STAGE_GEOMETRY, STAGE_FRAGMENT };
		int prev = -1;
		for (int o : order)
		{
			if (!present[o])
				continue;
			if (prev >= 0)
				LinkStages(stages[prev], stages[o], result);
			prev = o;
		}

		for (int st = 0; st < STAGE_COUNT; st++)
		{
			if (!present[st])
				continue;
			WrapMain(stages[st]);
			result.sources[st] = Assemble(stages[st], program.stages[st].extensions);
		}

		return result;
	}
}
