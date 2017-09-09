/// file_text_contents(filename)
/// @arg filename
/// @desc Returns the contents of a text file.

var fname, str;
fname = argument0
str = ""

if (file_exists_lib(fname))
{
	file_delete_lib(temp_file)
	file_copy_lib(fname, temp_file)
	var f = file_text_open_read(temp_file);
	if (f > -1)
	{
		while (!file_text_eof(f))
		{
			str += file_text_read_string(f) + "\n"
			file_text_readln(f)
		}
		file_text_close(f)
	}
}

return str
