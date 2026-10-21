#include "Generated/Scripts.hpp"

namespace CppProject
{
	IntType json_load_from_string(StringType json, IntType typeMapId = 0);

	IntType json_load(VarArgs args)
	{
		QFile file(args[0].ToStr());
		if (!file.open(QFile::ReadOnly))
			return -1;

		IntType typeMap = 0;
		if (args.Size() > 1)
			typeMap = args[1];
		
		return json_load_from_string(file.readAll(), typeMap);
	}

	StringType json_string_encode(StringType arg)
	{
		QString str = arg.QStr();
		IntType newLen = 0;
		for (QChar c : str)
		{
			if (c == '\n' || c == '\t' || c == '"' || c == '\\')
				newLen += 2;
			else if (c.unicode() > 127)
				newLen += 5;
			else
				newLen++;
		}

		if (str.length() == newLen)
			return arg;

		QString nstr;
		nstr.reserve(newLen);
		for (QChar c : str)
		{
			if (c == '\n')
				nstr += "\\n";
			else if (c == '\t')
				nstr += "\\t";
			else if (c == '"')
				nstr += "\\\"";
			else if (c == '\\')
				nstr += "\\\\";
			else if (c.unicode() > 127)
				nstr += "\\u" + QString("%1").arg(c.unicode(), 4, 16, QLatin1Char('0')).toLower();
			else
				nstr += c;
		}

		return nstr;
	}
}
