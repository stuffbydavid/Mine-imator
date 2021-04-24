/// buffer_read_short()
/// @desc Reads a 2 byte short integer.

function buffer_read_short()
{
	return real(buffer_read(buffer_current, buffer_s16))
}
