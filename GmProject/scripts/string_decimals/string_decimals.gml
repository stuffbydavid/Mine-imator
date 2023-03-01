/// string_decimals(value)
/// @arg value
/// @desc Converts a value into a string and removes trailing zeroes in the decimal part.

function string_decimals(val)
{
	if (floor(val) = val)
		return string(floor(val))
	
	var str, p;
	str = string_format(val, 1, 5)
	
	for (p = string_length(str); p > 0; p--)
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
}
