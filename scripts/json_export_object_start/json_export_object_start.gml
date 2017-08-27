/// json_export_object_start([name])
/// @arg [name]

if (json_add_comma)
	buffer_write_byte(e_json_char.COMMA)

if (!json_empty)
{
	buffer_write_byte(e_json_char.RETURN)
	buffer_write_byte(e_json_char.NEW_LINE)
}
else
	json_empty = false
	
// Indent
json_export_indent()

// Name (optional)
if (argument_count > 0)
{
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_string(argument[0])
	buffer_write_byte(e_json_char.QUOTE)
	buffer_write_byte(e_json_char.COLON)
	buffer_write_byte(e_json_char.SPACE)
}

// Begin object
buffer_write_byte(e_json_char.CURLY_BEGIN)

json_indent++
json_add_comma = false