/// buffer_read_int_be()
/// @desc Reads a 4-byte big endian integer.

function buffer_read_int_be()
{
	var byte;
	byte[0] = buffer_read_byte()
	byte[1] = buffer_read_byte()
	byte[2] = buffer_read_byte()
	byte[3] = buffer_read_byte()
	
	return byte[0] * 16777216 + byte[1] * 65536 + byte[2] * 256 + byte[3]
}
