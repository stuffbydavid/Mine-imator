/// string_decimals(value)
/// @arg value

var str, nstr, l;

if (string_count(".", string(argument0)) = 0)
	return string(argument0)

str = string_format(argument0, 1, 4)
nstr = str
l = string_length(str)

for (var p = l; p > 0; p--)
{
	var c;
	c = string_char_at(str, p)
	if (c = "0" || c = ".")
	{
		nstr = string_delete(nstr, p, 1)
		if (c = ".")
			break
	}
	else
		break
}

return nstr
