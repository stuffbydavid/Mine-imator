/// @arg [name]

function json_save_array_start(name = null)
{
	if (json_add_comma)
		buffer_write_byte(e_json_char.COMMA)
	buffer_write_byte(e_json_char.RETURN)
	buffer_write_byte(e_json_char.NEW_LINE)
	
	// Indent
	json_save_indent()
	
	// Name (optional)
	if (is_string(name))
	{
		buffer_write_byte(e_json_char.QUOTE)
		buffer_write_string(name)
		buffer_write_byte(e_json_char.QUOTE)
		buffer_write_byte(e_json_char.COLON)
		buffer_write_byte(e_json_char.SPACE)
	}
	
	// Begin list
	buffer_write_byte(e_json_char.SQUARE_BEGIN)
	
	json_indent++
	json_add_comma = false
}
