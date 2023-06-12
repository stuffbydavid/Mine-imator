/// draw_texture_slot(texture, slot, x, y, width, height, slotsx, slotsy, [color])
/// @arg texture
/// @arg slot
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg slotsx
/// @arg slotsy
/// @arg [color]

function draw_texture_slot(tex, slot, xx, yy, width, height, slotsx, slotsy, color = c_white)
{
	var slotwid, slothei, sx, sy, scale;
	
	slotwid = max(1, texture_width(tex) / slotsx)
	slothei = max(1, texture_height(tex) / slotsy)
	sx = (slot mod slotsx) * slotwid
	sy = (slot div slotsx) * slothei
	scale = min(width / slotwid, height / slothei)
	
	draw_texture_start()
	draw_texture_part(tex, xx, yy, sx, sy, slotwid, slothei, scale, scale, color, 1)
	draw_texture_done()
}
