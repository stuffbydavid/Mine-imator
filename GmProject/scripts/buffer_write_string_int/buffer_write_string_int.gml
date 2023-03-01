/// buffer_write_string_int(string)
/// @arg string
/// @desc Writes a string to the buffer, beginning with an integer telling the length in bytes.

function buffer_write_string_int(str)
{
	var len = string_length(str);
	
	buffer_write_int(len)
	for (var p = 0; p < len; p++)
		buffer_write_byte(ord(string_char_at(str, p + 1)))
}
