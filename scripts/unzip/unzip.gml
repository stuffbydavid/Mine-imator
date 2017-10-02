/// unzip(filename, [directory])
/// @arg filename
/// @arg [directory]

var fn, dir;
fn = argument[0]
dir = unzip_directory
if (argument_count > 1)
	dir = argument[1]

file_delete_lib(temp_file)
file_copy_lib(fn, temp_file)
directory_delete_lib(dir)

log("Unzipping", fn, dir)
return zip_unzip(temp_file, dir)
