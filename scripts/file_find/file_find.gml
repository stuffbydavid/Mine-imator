/// file_find(directory, extensions)
/// @arg directory
/// @arg extensions
/// @desc Returns an array of files in the given directory that has any of the given extensions.

var dir, exts, ret, ret_count, f;
dir = argument0
exts = argument1

ret = null
ret_count = 0

f = file_find_first(dir + "*", 0)
while (f != "")
{
	if (string_contains(exts, filename_ext(f)))
	{
		ret[ret_count] = dir + f
		ret_count++
	}
	f = file_find_next()
}
file_find_close()

return ret
