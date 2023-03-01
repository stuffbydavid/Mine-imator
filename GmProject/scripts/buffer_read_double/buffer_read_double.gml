/// buffer_read_double()
/// @desc Reads a double from the buffer.

function buffer_read_double()
{
	return real(buffer_read(buffer_current, buffer_f64))
}
