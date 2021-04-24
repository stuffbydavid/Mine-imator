/// string_line_array(string)
/// @arg string
/// @desc Returns an array of lines in a string

function string_line_array(str)
{
	str = str + "\n"
	var arr = array_create(string_count("\n", str));
	
	for (var i = array_length(arr) - 1; i > -1; i--)
	{
		var linepos = string_pos("\n", str);
		arr[i] = string_copy(str, 0, linepos - 1)
		
		str = string_delete(str, 1, linepos)
	}
	
	return arr
}
