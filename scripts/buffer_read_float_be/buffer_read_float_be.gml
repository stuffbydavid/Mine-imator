/// buffer_read_float_be()
/// @desc Reads a big endian float from the buffer.

var byte, tmpbuf, value;
for (var b = 0; b < 4; b++)
	byte[b] = buffer_read_byte()

tmpbuf = buffer_create(4, buffer_fixed, 1)
for (var b = 0; b < 4; b++)
	buffer_write(tmpbuf, buffer_u8, byte[3 - b])

buffer_seek(tmpbuf, 0, 0)
value = buffer_read(tmpbuf, buffer_f32)
buffer_delete(tmpbuf)

return value