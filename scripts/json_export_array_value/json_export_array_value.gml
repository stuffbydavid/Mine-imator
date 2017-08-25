/// json_export_array_value(value)
/// @arg value

var value = argument0;

if (json_add_comma)
	json_string += ","
	
json_string += "\n" + json_indent
json_export_value(value)
json_add_comma = true