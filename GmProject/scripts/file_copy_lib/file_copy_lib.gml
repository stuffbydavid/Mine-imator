/// file_copy_lib(source, destination)
/// @arg source
/// @arg destination

function file_copy_lib(src, dest)
{
	if (src = dest)
		return 0
	
	return external_call(lib_file_copy, src, dest)
}
