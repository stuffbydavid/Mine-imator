/// draw_surface_size(id, x, y, width, height)
/// @arg surface
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_surface_size(surf, xx, yy, w, h)
{
	if (surface_exists(surf))
		draw_surface_ext(surf, xx, yy, w / surface_get_width(surf), h / surface_get_height(surf), 0, -1, draw_get_alpha())
	else
		draw_box(xx, yy, w, h, false, c_black, draw_get_alpha())
}
