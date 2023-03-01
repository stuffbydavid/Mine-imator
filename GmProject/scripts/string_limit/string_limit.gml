/// string_limit(string, width, [ellipsis])
/// @arg string
/// @arg width
/// @arg [ellipsis]

function string_limit()
{
	var str, wid, ellipsis, nstr, pos;
	str = argument[0]
	wid = argument[1]
	ellipsis = "..."
	
	if (argument_count > 2)
		ellipsis = argument[2]
	
	if (string_width(ellipsis) > wid)
		return ""
	
	if (string_width(str) <= wid) 
		return str
	
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
