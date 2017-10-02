/// file_find(directory, extensions)
/// @arg directory
/// @arg extensions
/// @desc Returns an array of files in the given directory that has any of the given extensions.

var dir, exts, ret, f;
dir = argument0
exts = argument1

ret = array()

f = file_find_first(dir + "*", 0)
while (f != "")
{
	if (string_contains(exts, filename_ext(f)))
		ret[array_length_1d(ret)] = dir + f
	f = file_find_next()
}
file_find_close()

return ret