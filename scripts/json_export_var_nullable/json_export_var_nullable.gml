/// json_export_var_nullable(name, value)
/// @arg name
/// @arg value

var name, value;
name = argument0
value = argument1

if (json_add_comma)
	buffer_write_byte(e_json_char.COMMA)
	
buffer_write_byte(e_json_char.NEW_LINE)

// Indent
json_export_indent()
	
// Name
buffer_write_byte(e_json_char.QUOTE)
buffer_write_string(argument[0])
buffer_write_byte(e_json_char.QUOTE)
buffer_write_byte(e_json_char.COLON)
buffer_write_byte(e_json_char.SPACE)

// Value
if (value = null)
	buffer_write_string("null")
else
	json_export_value(value)

json_add_comma = true