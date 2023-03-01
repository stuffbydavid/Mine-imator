#include "Generated/GmlFunc.hpp"

#include "AppHandler.hpp"
#include "Asset/Font.hpp"
#include "Render/PrimitiveRenderer.hpp"

#include <QRegularExpression>

namespace CppProject
{
	StringType string_char_at(StringType str, IntType index)
	{
		index--;
		if (index < 0 || index >= str.GetLength())
			return "";
		return QString(str.At(index));
	}

	StringType string_copy(StringType str, IntType index, IntType count)
	{
		index--;
		if (index < 0)
			index = 0;
		return str.Mid(index, count);
	}

	IntType string_count(StringType substr, StringType str)
	{
		return str.Count(substr);
	}

	StringType string_delete(StringType str, IntType index, IntType count)
	{
		index--;
		return str.Removed(index, count);
	}

	StringType string_digits(StringType str)
	{
		return str.Replaced(QRegularExpression("[^\\d]"), "");
	}

	StringType string_format(RealType val, IntType tot, IntType dec)
	{
		QString text;
		if (dec == 0)
			text = QString::number((IntType)val);
		else
		{
			QString format = "%." + QString::number(dec) + "f";
			text = QString::asprintf(format.toStdString().c_str(), val);
		}

		// Add space in front to match at least tot characters
		while (text.length() < tot + (text.contains(".") ? 1 : 0))
			text = " " + text;
		return text;
	}

	IntType string_height_ext(StringType str, IntType sep, IntType w)
	{
		if (PR->font)
			return PR->font->GetTextHeight(PR->font->GetWrappedText(str, w));
		return 0;
	}

	IntType string_height(StringType str)
	{
		if (PR->font)
			return PR->font->GetTextHeight(str);
		return 0;
	}

	StringType string_insert(StringType substr, StringType str, IntType index)
	{
		index--;
		return str.Inserted(index, substr);
	}

	IntType string_length(StringType str)
	{
		return str.GetLength();
	}

	StringType string_lower(StringType str)
	{
		return str.ToLower();
	}

	IntType string_pos(StringType substr, StringType str)
	{
		if (substr.IsEmpty())
			return 0;

		return str.IndexOf(substr) + 1LL;
	}

	StringType string_repeat(StringType str, IntType num)
	{
		return str.Repeated(num);
	}

	StringType string_replace_all(StringType str, StringType substr, StringType newstr)
	{
		return str.Replaced(substr, newstr);
	}

	StringType string_replace(StringType str, StringType substr, StringType newstr)
	{
		return str.Replaced(str.IndexOf(substr), substr.GetLength(), newstr);
	}

	StringType string_upper(StringType str)
	{
		return str.ToUpper();
	}

	IntType string_width(StringType str)
	{
		if (PR->font)
			return PR->font->GetTextWidth(str);
		return 0;
	}

	StringType string(VarType v)
	{
		return v.ToStr();
	}
}
