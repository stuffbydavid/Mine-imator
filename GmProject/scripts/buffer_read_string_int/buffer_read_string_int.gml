/// @desc Reads a string consisting of a 4-byte integer and a number of UTF-8 characters.

function buffer_read_string_int()
{
	var str = "";
	repeat (real(buffer_read_int()))
		str += chr(buffer_read_byte())
	return str
}
