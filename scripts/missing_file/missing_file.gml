/// missing_file(filename)
/// @arg filename
/// @desc Shows a message that a file is missing.

log("Missing file", argument0)
show_message("The file " + argument0 + " could not be found. If you are running from an archive, extract all the files and try again. If problems persist, re-install the program.")
return false
