/// file_find_single(directory, extensions)
/// @arg directory
/// @arg extensions

var ret = file_find(argument0, argument1);
if (array_length_1d(ret) > 0)
	return ret[0]
else
	return ""