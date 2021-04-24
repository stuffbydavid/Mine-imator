/// draw_surface_exists(surface, x, y)
/// @arg surface
/// @arg x
/// @arg y

function draw_surface_exists(surf, xx, yy)
{
	if (surface_exists(surf))
		draw_surface_ext(surf, xx, yy, 1, 1, 0, c_white, draw_get_alpha())
}
