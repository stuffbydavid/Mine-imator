/// file_delete_lib(filename)
/// @arg filename

function file_delete_lib(fn)
{
	return external_call(lib_file_delete, fn)
}
