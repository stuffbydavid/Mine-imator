/// json_save_indent()

function json_save_indent()
{
	repeat (json_indent)
		buffer_write_byte(e_json_char.TAB)
}
