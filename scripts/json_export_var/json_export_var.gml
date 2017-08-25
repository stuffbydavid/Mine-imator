/// json_export_var(name, value)
/// @arg name
/// @arg value

var name, value;
name = argument0
value = argument1

if (json_add_comma)
	json_string += ","

json_string += "\n" + json_indent + "\"" + name + "\": "
json_export_value(value)
json_add_comma = true