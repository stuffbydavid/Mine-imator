/// @arg filename
/// @arg [originx]
/// @arg [originy]

function sprite_add_lib(fn, originx = 0, originy = 0)
{
	if (file_copy_temp)
	{
		var ext, tmpfile;
		ext = filename_ext(fn)
		tmpfile = filename_new_ext(temp_file, ext)
		file_copy_lib(fn, tmpfile)
		
		return sprite_add(tmpfile, 1, false, false, originx, originy)
	}
	else
		return sprite_add(fn, 1, false, false, originx, originy)
}
