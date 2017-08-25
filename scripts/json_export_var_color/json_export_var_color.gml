/// json_export_var_color(name, value)
/// @arg name
/// @arg value

var name, value;
name = argument0
value = argument1

if (json_add_comma)
	json_string += ","
	
json_string += "\n" + json_indent + "\"" + name + "\": "
json_string += "\"#" + color_to_hex(value) + "\""
json_add_comma = true