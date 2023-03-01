/// CppSeparate void buffer_write_string(StringType)
/// buffer_write_string(string)
/// @arg string
/// @desc Writes a string to the buffer.
function buffer_write_string(argument0) {

	var str = argument0;

	for (var p = 0; p < string_length(str); p++)
		buffer_write_byte(ord(string_char_at(str, p + 1)))



}
