/// buffer_read_int_uns()
/// @desc Reads a 4 byte unsigned integer.

function buffer_read_int_uns()
{
	return buffer_read(buffer_current, buffer_u32)
}
