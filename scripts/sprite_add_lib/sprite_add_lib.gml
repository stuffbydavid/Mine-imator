/// sprite_add_lib(filename, [xorg, yorg])
/// @arg filename
/// @arg [xorgin
/// @arg yorgin]

function sprite_add_lib()
{
	var origin_x, origin_y;
	origin_x = 0
	origin_y = 0
	
	if (argument_count > 1)
	{
		origin_x = argument[1]
		origin_y = argument[2]
	}
	
	if (file_copy_temp)
	{
		var ext, tmpfile;
		ext = filename_ext(argument[0])
		tmpfile = filename_new_ext(temp_file, ext)
		file_copy_lib(argument[0], tmpfile)
		return sprite_add(tmpfile, 1, false, false, origin_x, origin_y);
	}
	else
		return sprite_add(argument[0], 1, false, false, origin_x, origin_y)
}
