/// json_export_object_done()

buffer_write_byte(e_json_char.RETURN)
buffer_write_byte(e_json_char.NEW_LINE)

// Indent
json_indent--
json_export_indent()
	
// End list
buffer_write_byte(e_json_char.CURLY_END)

json_add_comma = true