/// json_export_var_bool(name, value)
/// @arg name
/// @arg value

var name, value;
name = argument0
value = argument1

if (json_add_comma)
	buffer_write_byte(e_json_char.COMMA)
	
buffer_write_byte(e_json_char.RETURN)
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
buffer_write_string(test(value, "true", "false"))

json_add_comma = true