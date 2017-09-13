/// buffer_read_string_short_be()
/// @desc Reads a string consisting of a big endian short, then that many utf - 8 characters.

gml_pragma("forceinline")

var str = "";
repeat (buffer_read_short_be())
	str += chr(buffer_read_byte())
return str
