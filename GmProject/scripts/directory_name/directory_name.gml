/// @desc C:\something\something\folder\ -> folder\
/// @arg directory

function directory_name(dir)
{
	return filename_name(filename_dir(dir + ".ext")) + "/"
}
