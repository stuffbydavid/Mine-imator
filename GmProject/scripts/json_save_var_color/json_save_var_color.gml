/// json_save_var_color(name, value)
/// @arg name
/// @arg value

function json_save_var_color(name, val)
{
	if (json_add_comma)
		buffer_write_byte(e_json_char.COMMA)
	
	buffer_write_byte(e_json_char.RETURN)
	buffer_write_byte(e_json_char.NEW_LINE)
	
	// Indent
	json_save_indent()
	
	// Name
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_string(name)
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_byte(e_json_char.COLON)
	buffer_write_byte(e_json_char.SPACE)
	
	// Value
	json_save_value("#" + color_to_hex(val))
	
	json_add_comma = true
}
