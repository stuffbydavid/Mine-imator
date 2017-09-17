/// json_save_array_start([name])
/// @arg [name]

if (json_add_comma)
	buffer_write_byte(e_json_char.COMMA)
buffer_write_byte(e_json_char.RETURN)
buffer_write_byte(e_json_char.NEW_LINE)

// Indent
json_save_indent()
	
// Name (optional)
if (argument_count > 0)
{
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_string(argument[0])
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_byte(e_json_char.COLON)
	buffer_write_byte(e_json_char.SPACE)
}

// Begin list
buffer_write_byte(e_json_char.SQUARE_BEGIN)

json_indent++
json_add_comma = false