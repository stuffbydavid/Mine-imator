/// json_string_encode(string)
/// @arg string

var str, nstr;
str = argument0
nstr = ""

for (var i = 0; i < string_length(str); i++)
{
	var c, cord;
	c = string_char_at(str, i + 1)
	cord = ord(c)
	
	if (c = "\n")
		nstr += "\\n"
	else if (c = "\t")
		nstr += "\\t"
	else if (c = "\"")
		nstr += "\\\""
	else if (c = "\\")
		nstr += "\\\\"
	else if (cord > 127)
		nstr += "\\u" + string_lower(dec_to_hex(cord, 4))
	else
		nstr += c
}

return nstr