/// string_limit(string, width, [ellipsis])
/// @arg string
/// @arg width
/// @arg [ellipsis]

function string_limit(str, wid, ellipsis = "...")
{
	if (string_width(ellipsis) > wid)
		return ""
	
	if (string_width(str) <= wid) 
		return str
	
	var nstr, pos;
	
	nstr = ""
	pos = 1
	while (pos <= string_length(str))
	{
		var char = string_char_at(str, pos)
		if (char = "\n")
			char = " "
		
		if (string_width(nstr + char + ellipsis) >= wid)
			break
		
		nstr += char
		pos++
	}
	
	return nstr + "..."
}
