/// json_export_var_nullable(name, value)
/// @arg name
/// @arg value

var name, value;
name = argument0
value = argument1

if (json_add_comma)
	json_string += ","
	
json_string += "\n" + json_indent + "\"" + name + "\": "
if (value = null)
	json_string += "null"
else
	json_export_value(value)
json_add_comma = true