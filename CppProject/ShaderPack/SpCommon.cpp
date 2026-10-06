#include "SpCommon.hpp"

#include <QDebug>
#include <QRegularExpression>

namespace ShaderPacks
{
	std::function<void(LogLevel, const QString&)> logHandler;

	static void Log(LogLevel level, const QString& msg)
	{
		if (logHandler)
		{
			logHandler(level, msg);
			return;
		}

		switch (level)
		{
			case LogLevel::Info: qInfo().noquote() << "[ShaderPack]" << msg; break;
			case LogLevel::Warning: qWarning().noquote() << "[ShaderPack]" << msg; break;
			case LogLevel::Error: qCritical().noquote() << "[ShaderPack]" << msg; break;
		}
	}

	void LogInfo(const QString& msg) { Log(LogLevel::Info, msg); }
	void LogWarning(const QString& msg) { Log(LogLevel::Warning, msg); }
	void LogError(const QString& msg) { Log(LogLevel::Error, msg); }

	static QString UnescapeProperty(const QString& in)
	{
		QString out;
		out.reserve(in.size());
		for (int i = 0; i < in.size(); i++)
		{
			QChar c = in[i];
			if (c != '\\' || i + 1 >= in.size())
			{
				out += c;
				continue;
			}

			QChar n = in[++i];
			switch (n.unicode())
			{
				case 't': out += '\t'; break;
				case 'n': out += '\n'; break;
				case 'r': out += '\r'; break;
				case 'f': out += '\f'; break;
				case 'u':
				{
					bool ok = false;
					uint code = in.mid(i + 1, 4).toUInt(&ok, 16);
					if (ok)
					{
						out += QChar(code);
						i += 4;
					}
					else
						out += n;
					break;
				}
				default: out += n; break;
			}
		}
		return out;
	}

	OrderedProperties ParseProperties(const QString& text)
	{
		OrderedProperties props;
		QStringList lines = text.split(QRegularExpression("\r\n|\r|\n"));

		for (int l = 0; l < lines.size(); l++)
		{
			QString line = lines[l];

			// Skip leading whitespace
			int start = 0;
			while (start < line.size() && (line[start] == ' ' || line[start] == '\t' || line[start] == '\f'))
				start++;

			if (start >= line.size())
				continue;

			// Comments
			if (line[start] == '#' || line[start] == '!')
				continue;

			// Join continuation lines (odd number of trailing backslashes)
			QString logical = line.mid(start);
			while (true)
			{
				int backslashes = 0;
				for (int i = logical.size() - 1; i >= 0 && logical[i] == '\\'; i--)
					backslashes++;

				if (backslashes % 2 == 0 || l + 1 >= lines.size())
				{
					if (backslashes % 2 == 1)
						logical.chop(1);
					break;
				}

				logical.chop(1);
				QString next = lines[++l];
				int ns = 0;
				while (ns < next.size() && (next[ns] == ' ' || next[ns] == '\t' || next[ns] == '\f'))
					ns++;
				logical += next.mid(ns);
			}

			// Find the end of the key
			int keyEnd = 0;
			while (keyEnd < logical.size())
			{
				QChar c = logical[keyEnd];
				if (c == '\\')
				{
					keyEnd += 2;
					continue;
				}
				if (c == '=' || c == ':' || c == ' ' || c == '\t' || c == '\f')
					break;
				keyEnd++;
			}
			keyEnd = qMin(keyEnd, (int)logical.size());

			QString key = UnescapeProperty(logical.left(keyEnd));

			// Skip separator
			int valueStart = keyEnd;
			while (valueStart < logical.size() && (logical[valueStart] == ' ' || logical[valueStart] == '\t' || logical[valueStart] == '\f'))
				valueStart++;
			if (valueStart < logical.size() && (logical[valueStart] == '=' || logical[valueStart] == ':'))
			{
				valueStart++;
				while (valueStart < logical.size() && (logical[valueStart] == ' ' || logical[valueStart] == '\t' || logical[valueStart] == '\f'))
					valueStart++;
			}

			QString value = UnescapeProperty(logical.mid(valueStart));
			props.Set(key, value.trimmed());
		}

		return props;
	}

	QString NormalizePackPath(const QString& path)
	{
		QStringList parts = QString(path).replace('\\', '/').split('/', Qt::SkipEmptyParts);
		QStringList result;
		for (const QString& part : parts)
		{
			if (part == ".")
				continue;
			if (part == "..")
			{
				if (!result.isEmpty())
					result.removeLast();
				continue;
			}
			result.append(part);
		}
		return result.join('/');
	}

	QString PackPathDir(const QString& path)
	{
		int slash = path.lastIndexOf('/');
		return slash < 0 ? QString() : path.left(slash);
	}

	bool ParseBool(const QString& value, bool def)
	{
		QString v = value.trimmed().toLower();
		if (v == "true" || v == "on" || v == "1" || v == "yes")
			return true;
		if (v == "false" || v == "off" || v == "0" || v == "no")
			return false;
		return def;
	}
}
