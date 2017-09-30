/// json_save_indent()

//gml_pragma("forceinline")

repeat (json_indent)
	buffer_write_byte(e_json_char.TAB)