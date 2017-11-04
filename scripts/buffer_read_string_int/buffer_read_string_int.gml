/// buffer_read_string_int()
/// @desc Reads a string consisting of an int, then that many utf-8 characters.

//gml_pragma("forceinline")

var str = "";
repeat (real(buffer_read_int()))
	str += chr(buffer_read_byte())
return str
