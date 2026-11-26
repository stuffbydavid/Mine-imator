/// CppSeparate StringType get_open_filenames_ext(StringType, StringType, StringType, StringType)

function get_open_filenames_ext(filter, filename, directory, title)
{
	return string(get_open_filename_ext(filter, filename, directory, title))
}
