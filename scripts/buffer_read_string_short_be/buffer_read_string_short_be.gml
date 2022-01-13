/// buffer_read_string_short_be()
/// @desc Reads a string consisting of a big endian short, then that many utf - 8 characters.

var str = "";
var str_length = buffer_read_short_be()
// Read UTF-8 text
// Avoid buffer_Read (str_buffer, buffer_text) reading the terminator causes subsequent read errors.
// Select to obtain the text range byte and then buffer_read.
var str_buffer = buffer_create(str_length, buffer_fixed, 1);
repeat (str_length){
	buffer_write(str_buffer,buffer_u8, buffer_read_byte())
}
buffer_seek(str_buffer, buffer_seek_start, 0);
str = buffer_read(str_buffer, buffer_text)
buffer_delete(str_buffer)
return str
