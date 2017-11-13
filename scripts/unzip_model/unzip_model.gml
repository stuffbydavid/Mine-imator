/// unzip_model(filename)
/// @arg filename
/// @desc Unzips the archive with the given filename and looks for valid models inside.

var fn, name, validfile;
fn = argument0
name = filename_new_ext(filename_name(fn), "")

unzip(fn)

// Look for project
validfile = file_find_single(unzip_directory, "json")
if (!file_exists_lib(validfile)) // Try sub-folder
	validfile = file_find_single(unzip_directory + name + "\\", "json")
if (!file_exists_lib(validfile)) // Try item models
	validfile = file_find_single(unzip_directory + "assets\\minecraft\\models\\item\\", ".json;")
if (!file_exists_lib(validfile)) // Try block models
	validfile = file_find_single(unzip_directory + "assets\\minecraft\\models\\block\\", ".json;")
	
if (!file_exists_lib(validfile))
	return ""

return validfile