/// string_limit(string, width)
/// @arg string
/// @arg width

var str, wid, nstr, pos;
str = argument0
wid = argument1

if (string_width("...") > wid)
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
		
    if (string_width(nstr + char + "...") >= wid)
        break
    
    nstr += char
    pos++
}

return nstr + "..."
