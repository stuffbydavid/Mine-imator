/// buffer_read_color(x, y, width)
/// @arg x
/// @arg y
/// @arg width
/// @desc Reads a color value from the selected buffer

var xx, yy, wid, off, r, g, b;
xx = argument0
yy = argument1
wid = argument2

off = (xx + yy * wid) * 4
r = real(buffer_peek(buffer_current, off, buffer_u8))
g = real(buffer_peek(buffer_current, off + 1, buffer_u8))
b = real(buffer_peek(buffer_current, off + 2, buffer_u8))

return make_color_rgb(r, g, b)