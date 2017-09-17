/// json_save_start(filename)
/// @arg filename
/// @desc Starts exporting formatted JSON to a text file.

json_filename = argument0
json_indent = 0
json_empty = true
json_add_comma = false

buffer_current = buffer_create(8, buffer_grow, 1)
