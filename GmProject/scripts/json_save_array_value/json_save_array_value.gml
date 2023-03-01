/// json_save_array_value(value)
/// @arg value

function json_save_array_value(val)
{
	if (json_add_comma)
		buffer_write_byte(e_json_char.COMMA)
	
	buffer_write_byte(e_json_char.RETURN)
	buffer_write_byte(e_json_char.NEW_LINE)
	
	// Indent
	json_save_indent()
	
	// Value
	json_save_value(val)
	
	json_add_comma = true
}
