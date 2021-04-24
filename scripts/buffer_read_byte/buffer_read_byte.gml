/// buffer_read_byte()
/// @desc Reads one byte from the buffer.

function buffer_read_byte()
{
	return real(buffer_read(buffer_current, buffer_u8))
}
