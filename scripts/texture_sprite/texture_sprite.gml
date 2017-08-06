/// texture_sprite(sprite, subimage)
/// @arg sprite
/// @arg subimage

var tmpfile = file_directory + "tmp.png";
file_delete_lib(tmpfile)
sprite_save(argument0, argument1, tmpfile)
return texture_create(tmpfile)
