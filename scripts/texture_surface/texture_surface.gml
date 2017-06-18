/// texture_surface(surface)
/// @arg surface

var tmpfile = file_directory + "tmp.png";
file_delete_lib(tmpfile)
surface_save(argument0, tmpfile)
return texture_create(tmpfile)
