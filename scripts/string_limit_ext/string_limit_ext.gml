/// string_limit_ext(string, width, height)
/// @arg string
/// @arg width
/// @arg height

function string_limit_ext(str, w, h)
{

	var nstr, lh, dx, dy, c, linestart, wordstart;
	nstr = ""
	lh = string_height(" ")
	dx = 0
	dy = 0
	
	if (lh > h || string_width("...") > w)
		return ""
	
	linestart = 1
	wordstart = 1
	
	for (var c = 1; c <= string_length(str); c++)
	{
		var char, charwid;
		char = string_char_at(str, c)
		charwid = string_width(char)
		
		if (char = "\n") // New line
		{ 
			dx = 0
			dy += lh
			
			if (dy + lh > h) // Final line, add dots
			{
				while (c > linestart && string_width(string_copy(str, linestart, c - linestart) + "...") > w)
					c--
				nstr += string_copy(str, linestart, c - linestart) + "..."
				c = linestart
				
				break
			}
			
			nstr += string_copy(str, linestart, c - linestart) + "\n"
			linestart = c + 1
		}
		else
		{
			if (char = " " || char = ", " || char = "." || char = "/" || char = "-") // New word
				wordstart = c + 1
			
			dx += charwid
			if (dx > w && c > 1) // Wrap
			{
				dy += lh
				
				if (dy + lh > h) // Final line, no more wrapping
				{
					while (c > linestart && string_width(string_copy(str, linestart, c - linestart) + "...") > w)
						c--
					nstr += string_copy(str, linestart, c - linestart) + "..."
					c = linestart
					
					break
				}
				
				if (linestart = wordstart) // Wrap letters
					wordstart = c
				
				nstr += string_copy(str, linestart, wordstart - linestart) + "\n"
				dx = string_width(string_copy(str, wordstart, c - wordstart + 1))
				linestart = wordstart
			
			}
		}
	}
	
	nstr += string_copy(str, linestart, c - linestart)
	
	return nstr
}
