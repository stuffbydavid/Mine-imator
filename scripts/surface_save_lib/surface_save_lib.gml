/// surface_save_lib(surface, filename)
/// @arg surface
/// @arg filename

var tmpfile = file_directory + "tmp.png";
file_delete_lib(tmpfile)
surface_save(argument0, tmpfile)
file_copy_lib(tmpfile, argument1)
