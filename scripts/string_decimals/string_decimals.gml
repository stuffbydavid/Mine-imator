/// string_decimals(value)
/// @arg value
/// @desc Converts a value into a string and removes trailing zeroes in the decimal part.

if (floor(argument0) = argument0)
	return string(argument0)

var str, p;
str = string_format(argument0, 1, 5)

for (var p = string_length(str); p > 0; p--)
{
	var c = string_char_at(str, p);
	if (c = ".")
	{
		p--
		break
	}
	else if (c != "0")
		break
}

return string_copy(str, 1, p)
