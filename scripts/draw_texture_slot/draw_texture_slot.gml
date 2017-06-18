/// draw_texture_slot(texture, slot, x, y, size, slotsx, slotsy, [color])
/// @arg texture
/// @arg slot
/// @arg x
/// @arg y
/// @arg size
/// @arg slotsx
/// @arg slotsy
/// @arg [color]

var tex, slot, xx, yy, size, slotsx, slotsy, color;
var slotwid, slothei, sx, sy, scale;
tex = argument[0]
slot = argument[1]
xx = argument[2]
yy = argument[3]
size = argument[4]
slotsx = argument[5]
slotsy = argument[6]
if (argument_count > 7)
	color = argument[7]
else
	color = c_white

slotwid = max(1, texture_width(tex) / slotsx)
slothei = max(1, texture_height(tex) / slotsy)
sx = (slot mod slotsx) * slotwid
sy = (slot div slotsx) * slothei
scale = min(size / slotwid, size / slothei)

draw_texture_part(tex, xx, yy, sx, sy, slotwid, slothei, scale, scale, color, 1)