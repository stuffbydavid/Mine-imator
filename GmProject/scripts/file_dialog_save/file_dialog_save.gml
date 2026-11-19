function file_dialog_save(filter, filename, directory, title)
{
	return string(get_save_filename_ext(filter, filename, directory, title))
}
