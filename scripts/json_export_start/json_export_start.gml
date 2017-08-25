/// json_export_start(filename)
/// @arg filename
/// @desc Starts exporting formatted JSON to a text file.

globalvar json_filename, json_indent, json_string, json_add_comma;
json_filename = argument0
json_indent = ""
json_string = ""
json_add_comma = false