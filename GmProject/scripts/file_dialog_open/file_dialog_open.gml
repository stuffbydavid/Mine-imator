function file_dialog_open(filter, filename, directory, title)
{
	return string(get_open_filename_ext(filter, filename, directory, title))
}
