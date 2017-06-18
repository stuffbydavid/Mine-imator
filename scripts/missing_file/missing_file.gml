/// missing_file(filename)
/// @arg filename

if (!file_exists_lib(argument0))
{
	log("Missing file", argument0)
	show_message("The file " + argument0 + " could not be found. Re-install the program.")
	return 1
}

return 0
