/// surface_save_lib(surface, filename)
/// @arg surface
/// @arg filename

function surface_save_lib(surf, fn)
{
	if (!file_copy_temp || string_contains(fn, file_directory_get()))
	{
		surface_save(surf, fn)
		return 0
	}
	file_delete_lib(temp_image)
	surface_save(surf, temp_image)
	file_copy_lib(temp_image, fn)
}
