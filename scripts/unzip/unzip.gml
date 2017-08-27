/// unzip(filename)
/// @arg filename

file_delete_lib(temp_file)
file_copy_lib(argument0, temp_file)

log("Unzipping", temp_file)
return zip_unzip(temp_file, unzip_directory)
