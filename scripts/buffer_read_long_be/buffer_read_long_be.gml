/// buffer_read_long_be()
/// @desc Reads a 8 byte big endian integer.

function buffer_read_long_be()
{
	var i1, i2;
	i1 = buffer_read_int_be()
	i2 = buffer_read_int_be()
	
	return i1 * 4294967296 + i2
}
