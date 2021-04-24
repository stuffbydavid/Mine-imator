/// buffer_load_lib(filename)
/// @arg filename

function buffer_load_lib(fn)
{
	if (file_copy_temp)
	{
		file_delete_lib(temp_file)
		file_copy_lib(fn, temp_file)
		return buffer_load(temp_file)
	}
	else
		return buffer_load(fn)
}
