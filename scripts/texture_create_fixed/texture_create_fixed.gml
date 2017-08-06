/// texture_create_fixed(filename, width, height)
/// @arg filename
/// @arg width
/// @arg height
/// @desc Create a fixed-size texture.

var fn, wid, hei, tex, ntex, surf;
fn = argument0
wid = argument1
hei = argument2

tex = texture_create(fn)
surf = surface_create(wid, hei)
surface_set_target(surf)
{
	draw_clear_alpha(c_black, 0)
	draw_texture(tex, 0, 0)
}
surface_reset_target()
ntex = texture_surface(surf)
surface_free(surf)
texture_free(tex)

return ntex
