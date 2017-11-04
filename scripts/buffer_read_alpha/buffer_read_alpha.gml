/// buffer_read_alpha(x, y, width)
/// @arg x
/// @arg y
/// @arg width
/// @desc Reads an alpha value from the selected color buffer

var xx, yy, wid;
xx = argument0
yy = argument1
wid = argument2

return real(buffer_peek(buffer_current, (xx + yy * wid) * 4 + 3, buffer_u8) / 255)