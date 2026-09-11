/// string_natural_value(value, digits)
/// @arg value
/// @arg digits

function string_natural_value(value, digits)
{
	var result, number;
	result = ""
	number = ""
	for (var i = 1; i <= string_length(value); i++)
	{
		var char = string_char_at(value, i)
		if (string_pos(char, "0123456789") > 0)
			number += char
		else
		{
			result += string_repeat("0", max(0, digits - string_length(number))) + number + char
			number = ""
		}
	}
	return result + string_repeat("0", max(0, digits - string_length(number))) + number
}
