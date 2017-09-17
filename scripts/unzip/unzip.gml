/// unzip(filename)
/// @arg filename

file_delete_lib(temp_file)
file_copy_lib(argument0, temp_file)
directory_delete_lib(unzip_directory)

log("Unzipping", argument0)
return zip_unzip(temp_file, unzip_directory)
