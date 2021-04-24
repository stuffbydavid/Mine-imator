/// buffer_write_int(value)
/// @arg value
/// @desc Writes an integer to the buffer

function buffer_write_int(val)
{
	buffer_write(buffer_current, buffer_s32, val)
}
