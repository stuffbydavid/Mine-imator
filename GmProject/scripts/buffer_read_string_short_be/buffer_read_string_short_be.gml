/// @desc Reads a string consisting of a 2-byte big endian short, then a number of UTF-8 characters.

function buffer_read_string_short_be()
{
	var str = "";
	repeat (buffer_read_short_be())
		str += chr(buffer_read_byte())
	return str
}
