/// sprite_export(sprite, subimage, filename)
/// @arg sprite
/// @arg subimage
/// @arg filename

var tmpfile = file_directory + "tmp.png";
file_delete_lib(tmpfile)
sprite_save(argument0, argument1, tmpfile)
file_copy_lib(tmpfile, argument2)
