/// buffer_write_float_be(value)
/// @arg value
/// @desc Writes a big endian float to the buffer

function buffer_write_float_be(val)
{
	var tmpbuf, byte;
	tmpbuf = buffer_create(4, buffer_fixed, 1)
	buffer_write(tmpbuf, buffer_f32, val)
	buffer_seek(tmpbuf, 0, 0)
	
	for (var b = 0; b < 4; b++)
		byte[b] = buffer_read(tmpbuf, buffer_s8)
	buffer_delete(tmpbuf)
	
	for (var b = 0; b < 4; b++)
		buffer_write_byte(byte[3 - b])
}
