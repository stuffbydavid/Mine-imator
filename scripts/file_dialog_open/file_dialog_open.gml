/// file_dialog_open(filter, filename, directory, title)
/// @arg filter
/// @arg filename
/// @arg directory
/// @arg title

function file_dialog_open(filter, filename, directory, title)
{
	return string(get_open_filename_ext(filter, filename, directory, title))
}
