/// draw_texture_slot(texture, slot, x, y, size, slotsx, [color])
/// @arg texture
/// @arg slot
/// @arg x
/// @arg y
/// @arg size
/// @arg slotsx
/// @arg [color]

var tex, slot, xx, yy, size, slotsx, color;
var slotsize, sx, sy;
tex = argument[0]
slot = argument[1]
xx = argument[2]
yy = argument[3]
size = argument[4]
slotsx = argument[5]
if (argument_count > 6)
	color = argument[6]
else
	color = c_white

slotsize = max(1, texture_width(tex) / slotsx)
sx = (slot mod slotsx) * slotsize
sy = (slot div slotsx) * slotsize
draw_texture_part(tex, xx, yy, sx, sy, slotsize, slotsize, size / slotsize, size / slotsize, color, 1)