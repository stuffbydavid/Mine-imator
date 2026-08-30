/// buffer_save_lib(buffer, filename)
/// @arg buffer
/// @arg filename

function buffer_save_lib(buffer, fn)
{
	if (!file_copy_temp || string_contains(fn, file_directory_get()))
	{
		buffer_save(buffer, fn)
		return 0
	}
	file_delete_lib(temp_file)
	buffer_save(buffer, temp_file)
	file_copy_lib(temp_file, fn)
}
