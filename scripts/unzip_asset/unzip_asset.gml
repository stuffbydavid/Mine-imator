/// unzip_asset(filename)
/// @arg filename
/// @desc Unzips the archive with the given filename and looks for valid files inside.

var fn, name, validfile;
fn = argument0
name = filename_new_ext(filename_name(fn), "")

unzip(fn)

// Look for project
validfile = file_find_single(unzip_directory, "miproject;.mproj;.mani;")
if (!file_exists_lib(validfile)) // Try sub-folder
	validfile = file_find_single(unzip_directory + name + "\\", "miproject;.mproj;.mani;")
	
// Look for object
if (!file_exists_lib(validfile))
	validfile = file_find_single(unzip_directory, "miobject;miparticles;.object;.particles;.json;")
if (!file_exists_lib(validfile)) // Try sub-folder
	validfile = file_find_single(unzip_directory + name + "\\", "miobject;miparticles;.object;.particles;.json;")
	
if (!file_exists_lib(validfile))
	return ""

return validfile