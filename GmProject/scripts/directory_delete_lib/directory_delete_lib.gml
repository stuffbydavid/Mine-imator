/// directory_delete_lib(directory)
/// @arg directory

function directory_delete_lib(dir)
{
	return external_call(lib_directory_delete, dir)
}
