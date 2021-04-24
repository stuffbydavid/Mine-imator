/// file_find_single(directory, extensions)
/// @arg directory
/// @arg extensions

function file_find_single(dir, exts)
{
	var ret = file_find(dir, exts);
	if (array_length(ret) > 0)
		return ret[0]
	else
		return ""
}
