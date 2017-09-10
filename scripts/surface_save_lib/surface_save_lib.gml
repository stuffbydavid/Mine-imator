/// surface_save_lib(surface, filename)
/// @arg surface
/// @arg filename

file_delete_lib(temp_image)
surface_save(argument0, temp_image)
file_copy_lib(temp_image, argument1)
