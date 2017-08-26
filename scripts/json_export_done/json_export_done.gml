/// json_export_done()
/// @desc Write generated string to file

buffer_resize(buffer_current, buffer_tell(buffer_current))
buffer_export(buffer_current, json_filename)
buffer_delete(buffer_current)