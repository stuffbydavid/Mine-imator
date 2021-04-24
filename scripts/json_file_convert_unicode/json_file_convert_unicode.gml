/// json_file_convert_unicode(source, destination)
/// @arg source
/// @arg destination

function json_file_convert_unicode(src, dest)
{
	return external_call(lib_json_file_convert_unicode, src, dest)
}
