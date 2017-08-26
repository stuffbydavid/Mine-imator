/// buffer_write_string(string)
/// @arg string
/// @desc Writes a string to the buffer.

gml_pragma("forceinline")

var str = argument0;

for (var p = 0; p < string_length(str); p++)
	buffer_write_byte(ord(string_char_at(str, p + 1)))
