/// string_split(string, separator)
/// @arg string
/// @arg separator
/// @desc Splits the given string by the separator and stores the elements in a new array.

function string_split(str, sep)
{
	var arr, arrlen, pos, escapestr;
	arr = array()
	arrlen = 0
	str += sep
	escapestr = ""
	
	while (true)
	{
		// Look for separator
		var pos = string_pos(sep, str);
		if (pos = 0)
			break
		
		// Save escaped characters
		var escapepos = string_pos("\\" + sep, str);
		if (escapepos > 0 && escapepos < pos)
		{
			escapestr += string_copy(str, 1, escapepos - 1) + sep
			str = string_delete(str, 1, escapepos + 1)
			continue
		}
		
		// Add to array
		arr[arrlen++] = escapestr + string_copy(str, 1, pos - 1)
		str = string_delete(str, 1, pos)
		escapestr = ""
	}
	
	return arr
}
