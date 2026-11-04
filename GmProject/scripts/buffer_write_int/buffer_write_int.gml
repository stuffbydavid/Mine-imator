/// @desc Writes an integer to the buffer.
/// @arg value

function buffer_write_int(val)
{
	buffer_write(buffer_current, buffer_s32, val)
}
