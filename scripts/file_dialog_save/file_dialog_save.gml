/// file_dialog_save(filter, filename, directory, title)
/// @arg filter
/// @arg filename
/// @arg directory
/// @arg title

function file_dialog_save(filter, filename, directory, title)
{
	return string(get_save_filename_ext(filter, filename, directory, title))
}
