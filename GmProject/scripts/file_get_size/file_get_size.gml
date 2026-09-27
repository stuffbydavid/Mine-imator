/// CppSeparate IntType file_get_size(StringType)
function file_get_size(filename)
{
	var data = buffer_load_lib(filename)
	var size = buffer_get_size(data)
	buffer_delete(data)
	return size
}
