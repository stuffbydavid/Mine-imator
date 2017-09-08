/// sprite_add_lib(filename)
/// @arg filename

var ext, tmpfile;
ext = filename_ext(argument0)
tmpfile = filename_new_ext(temp_file, ext)

file_copy_lib(argument0, tmpfile)
return sprite_add(tmpfile, 1, false, false, 0, 0)