/// buffer_save_lib(buffer, filename)
/// @arg buffer
/// @arg filename

if (file_copy_temp)
{
	file_delete_lib(temp_file)
	buffer_save(argument0, temp_file)
	file_copy_lib(temp_file, argument1)
}
else
	buffer_save(argument0, argument1)