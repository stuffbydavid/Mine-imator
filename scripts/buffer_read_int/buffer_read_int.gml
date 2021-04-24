/// buffer_read_int()
/// @desc Reads a 4 byte integer.

function buffer_read_int()
{
	return real(buffer_read(buffer_current, buffer_s32))
}
