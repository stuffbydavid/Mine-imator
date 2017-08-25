/// json_export_done()
/// @desc Write generated string to file

file_delete_lib(temp_file)

var f = file_text_open_write(temp_file);
file_text_write_string(f, json_string)
file_text_close(f)

file_copy_lib(temp_file, json_filename)