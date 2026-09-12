/// file_dialog_open_multiple(filter, filename, directory, title)
/// @arg filter
/// @arg filename
/// @arg directory
/// @arg title

function file_dialog_open_multiple(filter, filename, directory, title)
{
	return string(get_open_filenames_ext(filter, filename, directory, title))
}