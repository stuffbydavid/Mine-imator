/// missing_file(filename)
/// @arg filename
/// @desc Shows a message that a file is missing.

function missing_file(fn)
{
	log("Missing file", fn)
	show_message("The file " + fn + " could not be found. If you are running from an archive, extract all the files and try again. If problems persist, re-install the program.")
	return false
}
