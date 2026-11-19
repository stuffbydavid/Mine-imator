/// @desc Reads an alpha value from the selected color buffer.
/// @arg x
/// @arg y
/// @arg width

function buffer_read_alpha(xx, yy, wid)
{
	return real(buffer_peek(buffer_current, (xx + yy * wid) * 4 + 3, buffer_u8) / 255)
}
