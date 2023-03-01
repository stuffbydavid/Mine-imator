/// filename_get_unique(filename)
/// @arg filename
/// @desc If the given filename exists, add a number to it.

function filename_get_unique(fn)
{
	var num, newfn, path, noext, ext;
	num = 2
	newfn = fn
	path = filename_dir(fn) + "/"
	noext = filename_new_ext(filename_name(fn), "")
	ext = filename_ext(filename_name(fn))
	
	while (file_exists_lib(newfn))
		newfn = path + noext + " (" + string(num++) + ")" + ext
	
	return newfn
}
