/// draw_surface_box_center(surface, x, y, width, height)
/// @arg surface
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var surf, xx, yy, w, h;
var sw, sh, scale;
surf = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4

if (!surface_exists(surf))
	return 0
	
sw = surface_get_width(surf)
sh = surface_get_height(surf)

if (sw / sh < w / h)
{
	scale = h / sh
	xx += (w - scale * sw) / 2
	w = sw * scale
}
else
{
	scale = w / sw
	yy += (h - scale * sh) / 2
	h = sh * scale
}

xx = floor(xx)
yy = floor(yy)
w = ceil(w)
h = ceil(h)

draw_surface_ext(surf, xx, yy, scale, scale, 0, c_white, 1)
