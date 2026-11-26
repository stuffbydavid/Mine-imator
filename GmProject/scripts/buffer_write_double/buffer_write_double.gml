/// @desc Writes a double to the buffer.
/// @arg value

function buffer_write_double(val)
{
	buffer_write(buffer_current, buffer_f64, val)
}
