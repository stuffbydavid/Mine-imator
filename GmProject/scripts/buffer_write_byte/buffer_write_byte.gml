/// @desc Writes a byte to the buffer.
/// @arg value

function buffer_write_byte(val)
{
	buffer_write(buffer_current, buffer_u8, val)
}
