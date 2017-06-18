/// string_split(string, separator)
/// @arg string
/// @arg separator
/// @desc Splits the given string by the separator and stores the elements in a new array.

var str, sep, arr, arrlen, pos;
str = argument0
sep = argument1

arr[0] = 0
arrlen = 0
str += sep

while (true)
{
	var pos = string_pos(sep, str);
	if (pos = 0)
		break
	arr[arrlen++] = string_copy(str, 1, pos - 1)
	str = string_delete(str, 1, pos)
}

return arr