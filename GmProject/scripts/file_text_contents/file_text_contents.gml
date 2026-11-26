/// @desc Returns the contents of a text file.
/// @arg filename

function file_text_contents(fn)
{
	var str, line;
	str = ""
	line = 0
	
	if (file_exists_lib(fn))
	{
		file_delete_lib(temp_file)
		file_copy_lib(fn, temp_file)
		var f = file_text_open_read(temp_file);
		if (f > -1)
		{
			while (!file_text_eof(f))
			{
				if (line++ > 0)
					str += "\n"
				str += file_text_read_string(f)
				file_text_readln(f)
			}
			file_text_close(f)
		}
	}
	
	return str
}
