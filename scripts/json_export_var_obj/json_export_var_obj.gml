/// json_export_var_obj(name, obj)
/// @arg name
/// @arg obj

var name, obj;
name = argument0
obj = argument1

if (json_add_comma)
	json_string += ","
	
json_string += "\n" + json_indent + "\"" + name + "\": "
if (obj = null)
	json_string += "null"
else
{
	json_string += "\"" + save_id_get(obj) + "\""
	obj.save = true
}
json_add_comma = true