/// directory_exists_lib(directory)
/// @arg directory

function directory_exists_lib(dir)
{
	if (dir = "")
		return 0
	
	return external_call(lib_directory_exists, dir)
}
