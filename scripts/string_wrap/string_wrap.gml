/// string_word_wrap(string, width)
/// @arg string
/// @arg width

var str, wid;
str = argument0
wid = argument1

var pos, insertpos, linewid;
pos = 1
insertpos = -1
linewid = 0
for (pos = 1; pos <= string_length(str); pos++)
{
	var ch = string_char_at(str, pos);
	if (ch = "\n")
	{
		linewid = 0
		continue
	}
	
	linewid += string_width(ch)
	if (linewid >= wid)
	{
		if (insertpos = -1)
		{
			str = string_insert("\n", str,pos)
			linewid = 0
		}
		else
		{
			str = string_insert("\n", str, insertpos)
			linewid = string_width(string_copy(str, insertpos, pos - insertpos + 1))
			insertpos = -1
		}
	}
	
	if (ch = " " || ch = "-")
		insertpos = pos + 1
}

return str
