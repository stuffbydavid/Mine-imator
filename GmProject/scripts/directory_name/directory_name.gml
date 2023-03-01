/// directory_name(directory)
/// @arg directory
/// @desc C:\something\something\folder\ -> folder\

function directory_name(dir)
{
	return filename_name(filename_dir(dir + ".ext")) + "/";
}
