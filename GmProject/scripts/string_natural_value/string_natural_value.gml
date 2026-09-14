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
		var c = string_char_at(value, i)
		if (ord(c) >= ord("0") && ord(c) <= ord("9"))
			number += c
		else
		{
			result += string_repeat("0", max(0, digits - string_length(number))) + number + c
			number = ""
		}
	}
	return result + string_repeat("0", max(0, digits - string_length(number))) + number
}
