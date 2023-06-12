/// buffer_read_short_be()
/// @desc Reads a 2 byte big endian short integer.

function buffer_read_short_be()
{
	var byte;
	byte[0] = buffer_read_byte()
	byte[1] = buffer_read_byte()
	
	return byte[0] * 256 + byte[1]
}
