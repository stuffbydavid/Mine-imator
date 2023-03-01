/// buffer_read_float()
/// @desc Reads a float from the buffer.

function buffer_read_float()
{
	return real(buffer_read(buffer_current, buffer_f32))
}
