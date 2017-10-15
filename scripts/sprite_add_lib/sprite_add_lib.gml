/// sprite_add_lib(filename)
/// @arg filename

if (file_copy_temp)
{
	var ext, tmpfile;
	ext = filename_ext(argument0)
	tmpfile = filename_new_ext(temp_file, ext)
	file_copy_lib(argument0, tmpfile)
	return sprite_add(tmpfile, 1, false, false, 0, 0);
}
else
	return sprite_add(argument0, 1, false, false, 0, 0)