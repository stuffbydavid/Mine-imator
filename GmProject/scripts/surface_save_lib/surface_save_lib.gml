/// surface_save_lib(surface, filename)
/// @arg surface
/// @arg filename

function surface_save_lib(surf, fn)
{
	file_delete_lib(temp_image)
	surface_save(surf, temp_image)
	file_copy_lib(temp_image, fn)
}
