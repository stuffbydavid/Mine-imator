/// texture_surface(surface)
/// @arg surface

var tmpfile = file_directory + "tmp.png";
surface_save_lib(argument0, tmpfile)
return texture_create(tmpfile)