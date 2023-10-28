/// language_load_legacy(filename, map)
/// @arg filename
/// @arg map

function language_load_legacy(fn, map)
{
	if (!file_exists_lib(fn))
		return 0
	
	file_copy_lib(fn, temp_file)
	
	var f = file_text_open_read(temp_file);
	while (!file_text_eof(f))
	{
		var line, commapos;
		line = file_text_read_string(f)
		commapos = string_pos(":", line)
		
		if (commapos > 0)
		{
			var key, val;
			key = string_copy(line, 1, commapos - 1)
			val = string_delete(line, 1, commapos + 1)
			map[?key] = val
		}
		
		file_text_readln(f);
	}
	
	file_text_close(f)
}
