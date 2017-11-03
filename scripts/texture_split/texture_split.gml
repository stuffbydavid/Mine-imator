/// texture_split(texture, slotsx, slotsy)
/// @arg texture
/// @arg slotsx
/// @arg slotsy
/// @desc Returns an array of texture pieces.

var tex, slotsx, slotsy, w, h, sw, sh, newtex, surf;
tex = argument0
slotsx = argument1
slotsy = argument2

w = texture_width(tex)
h = texture_height(tex)
sw = max(1, w div slotsx)
sh = max(1, h div slotsy)

draw_texture_start()
surf = surface_create(sw, sh)
surface_set_target(surf)
{
	for (var i = 0; i < slotsx * slotsy; i++)
	{
		var dx, dy;
		dx = (i mod slotsx) * sw
		dy = (i div slotsx) * sh
		draw_clear_alpha(c_black, 0)
		draw_texture_part(tex, 0, 0, dx, dy, sw, sh)
		newtex[i] = texture_surface(surf)
	}
}
surface_reset_target()
surface_free(surf)
draw_texture_done()

return newtex
