/// filename_get_unique(filename)
/// @arg filename
/// @desc If the given filename exists, add a number to it.

function filename_get_unique(fn)
{
	var num = 2;
	var newfn = fn;
	while (file_exists_lib(newfn))
		newfn = filename_new_ext(fn, "") + " (" + string(num++) + ")" + filename_ext(fn)
	
	return newfn
}
