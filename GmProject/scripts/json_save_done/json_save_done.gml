/// json_save_done()
/// @desc Write generated string to file

function json_save_done()
{
	buffer_resize(buffer_current, buffer_tell(buffer_current))
	buffer_save_lib(buffer_current, json_filename)
	buffer_delete(buffer_current)
}
