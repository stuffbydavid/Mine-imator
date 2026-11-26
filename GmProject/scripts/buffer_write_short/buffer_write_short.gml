/// @desc Writes a short integer to the buffer.
/// @arg value

function buffer_write_short(val)
{
	buffer_write(buffer_current, buffer_u16, val)
}
