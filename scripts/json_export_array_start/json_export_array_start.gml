/// json_export_array_start([name])
/// @arg [name]

if (json_add_comma)
	json_string += ","

json_string += "\n" + json_indent
if (argument_count > 0)
	json_string += "\"" + argument[0] + "\": "
json_string += "["
json_indent += "\t"

json_add_comma = false