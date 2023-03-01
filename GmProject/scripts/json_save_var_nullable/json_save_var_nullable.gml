/// json_save_var_nullable(name, value)
/// @arg name
/// @arg value

function json_save_var_nullable(name, val)
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
	if (val = null)
		json_save_value("null")
	else
		json_save_value(val)
	
	json_add_comma = true
}
