#include "SpOptions.hpp"
#include "SpPackFiles.hpp"

#include <QRegularExpression>

namespace ShaderPacks
{
	namespace
	{
		// Const options that may be configured (from OptionAnnotatedSource in Iris)
		bool IsValidConstOption(const QString& name)
		{
			static QSet<QString> valid;
			if (valid.isEmpty())
			{
				valid = {
					"shadowMapResolution", "shadowDistance", "voxelDistance", "shadowDistanceRenderMul", "entityShadowDistanceMul",
					"shadowIntervalSize", "generateShadowMipmap", "generateShadowColorMipmap", "shadowHardwareFiltering",
					"shadowtex0Mipmap", "shadowtexMipmap", "shadowtex1Mipmap", "shadowtex0Nearest", "shadowtexNearest",
					"shadow0MinMagNearest", "shadowtex1Nearest", "shadow1MinMagNearest", "wetnessHalflife", "drynessHalflife",
					"eyeBrightnessHalflife", "centerDepthHalflife", "sunPathRotation", "ambientOcclusionLevel",
					"superSamplingLevel", "noiseTextureResolution"
				};
				for (int i = 0; i < 8; i++)
				{
					QString n = QString::number(i);
					valid << "shadowcolor" + n + "Mipmap" << "shadowColor" + n + "Mipmap" << "shadowcolor" + n + "Nearest"
						  << "shadowColor" + n + "Nearest" << "shadowcolor" + n + "MinMagNearest" << "shadowColor" + n + "MinMagNearest"
						  << "shadowHardwareFiltering" + n;
				}
			}
			return valid.contains(name);
		}

		// Minimal string scanner mirroring Iris' ParsedString
		struct Scanner
		{
			QString s;
			int p = 0;

			Scanner(const QString& str) : s(str) {}

			bool AtEnd() const { return p >= s.size(); }

			bool TakeLiteral(const QString& lit)
			{
				if (s.midRef(p, lit.size()) == lit)
				{
					p += lit.size();
					return true;
				}
				return false;
			}

			bool TakeSomeWhitespace()
			{
				int start = p;
				while (p < s.size() && s[p].isSpace())
					p++;
				return p > start;
			}

			QString TakeWord()
			{
				int start = p;
				while (p < s.size() && (s[p].isLetterOrNumber() || s[p] == '_'))
					p++;
				return p > start ? s.mid(start, p - start) : QString();
			}

			QString TakeWordOrNumber()
			{
				int start = p;
				while (p < s.size() && (s[p].isLetterOrNumber() || s[p] == '_' || s[p] == '.' || s[p] == '-' || s[p] == '+'))
					p++;
				return p > start ? s.mid(start, p - start) : QString();
			}

			bool TakeComments()
			{
				return TakeLiteral("//");
			}

			QString TakeRest()
			{
				QString r = s.mid(p);
				p = s.size();
				return r;
			}

			bool CurrentlyContains(const QString& str) const
			{
				return s.indexOf(str, p) >= 0;
			}
		};

		QString EditConst(const QString& line, const QString& oldValue, const QString& newValue)
		{
			int eq = line.indexOf('=');
			if (eq < 0)
				return line;
			int semi = line.indexOf(';', eq);
			if (semi < 0)
				return line;
			return line.left(eq + 1) + " " + newValue + line.mid(semi);
		}
	}

	void Options::Discover(const IncludeResolver& includes, const QStringList& files)
	{
		options.clear();
		order.clear();
		lineOptions.clear();

		struct Candidate
		{
			Option option;
			QString file;
			int line;
		};
		QVector<Candidate> booleanCandidates, stringCandidates;
		QSet<QString> referenced;

		for (const QString& file : files)
		{
			const QStringList* lines = includes.Lines(file);
			if (!lines)
				continue;

			for (int l = 0; l < lines->size(); l++)
			{
				const QString& text = lines->at(l);
				if (!text.contains("#define") && !text.contains("const") && !text.contains("#ifdef") && !text.contains("#ifndef"))
					continue;

				Scanner line(text.trimmed());

				// #ifdef / #ifndef references
				if (line.TakeLiteral("#ifdef") || line.TakeLiteral("#ifndef"))
				{
					if (!line.TakeSomeWhitespace())
						continue;
					QString name = line.TakeWord();
					line.TakeSomeWhitespace();
					if (!name.isEmpty() && line.AtEnd())
						referenced.insert(name);
					continue;
				}

				// const options
				if (line.TakeLiteral("const"))
				{
					if (!line.TakeSomeWhitespace())
						continue;

					bool isString;
					if (line.TakeLiteral("int") || line.TakeLiteral("float"))
						isString = true;
					else if (line.TakeLiteral("bool"))
						isString = false;
					else
						continue;

					if (!line.TakeSomeWhitespace())
						continue;
					QString name = line.TakeWord();
					if (name.isEmpty())
						continue;
					line.TakeSomeWhitespace();
					if (!line.TakeLiteral("="))
						continue;
					line.TakeSomeWhitespace();
					QString value = line.TakeWordOrNumber();
					if (value.isEmpty())
						continue;
					line.TakeSomeWhitespace();
					if (!line.TakeLiteral(";"))
						continue;
					line.TakeSomeWhitespace();

					QString comment;
					if (line.TakeComments())
						comment = line.TakeRest().trimmed();
					else if (!line.AtEnd())
						continue;

					if (!IsValidConstOption(name))
						continue;

					Option opt;
					opt.name = name;
					opt.source = Option::CONST;
					if (!isString)
					{
						if (value != "true" && value != "false")
							continue;
						opt.kind = Option::BOOLEAN;
						opt.defaultValue = value;
						opt.comment = comment;
						booleanCandidates.append({ opt, file, l });
						referenced.insert(name); // Const booleans don't need references
					}
					else
					{
						int open = comment.indexOf('[');
						int close = open >= 0 ? comment.indexOf(']', open) : -1;
						if (open < 0 || close < 0)
							continue;
						opt.kind = Option::STRING;
						opt.defaultValue = value;
						opt.allowedValues = comment.mid(open + 1, close - open - 1).split(' ', Qt::SkipEmptyParts);
						if (!opt.allowedValues.contains(value))
							opt.allowedValues.append(value);
						opt.comment = (comment.left(open) + comment.mid(close + 1)).trimmed();
						stringCandidates.append({ opt, file, l });
					}
					continue;
				}

				// #define options
				if (!line.CurrentlyContains("#define"))
					continue;

				bool hasLeadingComment = line.TakeComments();
				line.TakeSomeWhitespace();
				if (!line.TakeLiteral("#define"))
					continue;
				if (!line.TakeSomeWhitespace())
					continue;
				QString name = line.TakeWord();
				if (name.isEmpty())
					continue;

				bool tookWhitespace = line.TakeSomeWhitespace();

				if (line.AtEnd())
				{
					Option opt;
					opt.name = name;
					opt.kind = Option::BOOLEAN;
					opt.defaultValue = hasLeadingComment ? "false" : "true";
					booleanCandidates.append({ opt, file, l });
					continue;
				}

				if (line.TakeComments())
				{
					Option opt;
					opt.name = name;
					opt.kind = Option::BOOLEAN;
					opt.defaultValue = hasLeadingComment ? "false" : "true";
					opt.comment = line.TakeRest().trimmed();
					booleanCandidates.append({ opt, file, l });
					continue;
				}

				if (!tookWhitespace || hasLeadingComment)
					continue;

				QString value = line.TakeWordOrNumber();
				if (value.isEmpty())
					continue;

				tookWhitespace = line.TakeSomeWhitespace();
				if (line.AtEnd())
					continue;
				if (!line.TakeComments())
					continue;

				QString comment = line.TakeRest().trimmed();
				int open = comment.indexOf('[');
				int close = open >= 0 ? comment.indexOf(']', open) : -1;
				if (open < 0 || close < 0)
					continue;

				Option opt;
				opt.name = name;
				opt.kind = Option::STRING;
				opt.defaultValue = value;
				opt.allowedValues = comment.mid(open + 1, close - open - 1).split(' ', Qt::SkipEmptyParts);
				if (!opt.allowedValues.contains(value))
					opt.allowedValues.append(value);
				opt.comment = (comment.left(open) + comment.mid(close + 1)).trimmed();
				stringCandidates.append({ opt, file, l });
			}
		}

		// Boolean define options require a #ifdef/#ifndef reference somewhere in the pack
		for (const Candidate& c : booleanCandidates)
		{
			if (!referenced.contains(c.option.name))
				continue;
			if (options.contains(c.option.name) && options[c.option.name].kind != Option::BOOLEAN)
				continue;
			if (!options.contains(c.option.name))
			{
				options[c.option.name] = c.option;
				order.append(c.option.name);
			}
			lineOptions[{ c.file, c.line }] = c.option.name;
		}

		for (const Candidate& c : stringCandidates)
		{
			if (options.contains(c.option.name) && options[c.option.name].kind != Option::STRING)
				continue;
			if (!options.contains(c.option.name))
			{
				options[c.option.name] = c.option;
				order.append(c.option.name);
			}
			else
			{
				// Merge allowed values
				Option& existing = options[c.option.name];
				for (const QString& v : c.option.allowedValues)
					if (!existing.allowedValues.contains(v))
						existing.allowedValues.append(v);
			}
			lineOptions[{ c.file, c.line }] = c.option.name;
		}
	}

	QString Options::Value(const QString& name) const
	{
		auto it = values.constFind(name);
		if (it != values.constEnd())
			return it.value();
		auto opt = options.constFind(name);
		if (opt != options.constEnd())
			return opt->defaultValue;
		return QString();
	}

	bool Options::BoolValue(const QString& name) const
	{
		return Value(name) == "true";
	}

	bool Options::SetValue(const QString& name, const QString& value)
	{
		auto opt = options.constFind(name);
		if (opt == options.constEnd())
			return false;

		QString v = value.trimmed();
		if (opt->kind == Option::BOOLEAN)
		{
			v = ParseBool(v, opt->defaultValue == "true") ? "true" : "false";
		}

		if (v == opt->defaultValue)
			values.remove(name);
		else
			values[name] = v;
		return true;
	}

	QString Options::ApplyToLine(const QString& file, int line, const QString& text) const
	{
		auto it = lineOptions.constFind({ file, line });
		if (it == lineOptions.constEnd())
			return text;

		const Option& opt = options[it.value()];
		auto valIt = values.constFind(opt.name);
		if (valIt == values.constEnd())
			return text;
		QString value = valIt.value();

		if (opt.kind == Option::BOOLEAN)
		{
			bool enabled = (value == "true");
			if (opt.source == Option::DEFINE)
			{
				QString trimmed = text.trimmed();
				bool commented = trimmed.startsWith("//");
				if (enabled && commented)
				{
					// Remove the leading comment
					int pos = text.indexOf("//");
					QString rest = text.mid(pos + 2);
					return rest;
				}
				if (!enabled && !commented)
					return "//" + text;
				return text;
			}
			return EditConst(text, opt.defaultValue, value);
		}

		if (opt.source == Option::DEFINE)
			return "#define " + opt.name + " " + value + " // Changed option";
		return EditConst(text, opt.defaultValue, value);
	}

	void Options::LoadSettings(const QString& text)
	{
		OrderedProperties props = ParseProperties(text);
		for (const QString& key : props.keys)
			SetValue(key, props.Get(key));
	}

	QString Options::SaveSettings() const
	{
		QString out;
		QStringList keys = values.keys();
		keys.sort();
		for (const QString& key : keys)
			out += key + "=" + values[key] + "\n";
		return out;
	}

	QStringList Options::ApplyProfile(const QString& profile, const QHash<QString, QString>& profiles)
	{
		QStringList disabledPrograms;
		QSet<QString> visited;

		std::function<void(const QString&)> apply = [&](const QString& name)
		{
			if (visited.contains(name) || !profiles.contains(name))
				return;
			visited.insert(name);

			for (const QString& entry : profiles[name].split(QRegularExpression("\\s+"), Qt::SkipEmptyParts))
			{
				if (entry.startsWith("profile."))
					apply(entry.mid(8));
				else if (entry.startsWith("!program."))
					disabledPrograms.append(entry.mid(9));
				else if (entry.startsWith('!'))
					SetValue(entry.mid(1), "false");
				else if (entry.contains('=') || entry.contains(':'))
				{
					int sep = entry.indexOf(QRegularExpression("[=:]"));
					SetValue(entry.left(sep), entry.mid(sep + 1));
				}
				else
					SetValue(entry, "true");
			}
		};

		apply(profile);
		return disabledPrograms;
	}

	void LanguageMap::Load(const QString& text)
	{
		OrderedProperties props = ParseProperties(text);
		for (const QString& key : props.keys)
			entries[key] = props.Get(key);
	}
}
