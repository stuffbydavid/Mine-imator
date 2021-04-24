/// file_exists_lib(filename)
/// @arg filename

function file_exists_lib(fn)
{
	if (fn = "")
		return 0
	
	return external_call(lib_file_exists, fn)
}
