/// directory_name(directory)
/// @arg directory
/// @desc C:\something\something\folder\ -> folder\

function directory_name(argument0)
{
	return filename_name(filename_dir(argument0 + ".ext")) + "\\";
}
