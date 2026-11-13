/// CppSeparate IntType file_get_size(StringType)

function file_get_size(filename)
{
	var data, size;
	data = buffer_load_lib(filename)
	size = buffer_get_size(data)
	buffer_delete(data)
	return size
}
