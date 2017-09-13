/// draw_surface_exists(surface, x, y)
/// @arg surface
/// @arg x
/// @arg y

gml_pragma("forceinline")

if (surface_exists(argument0))
	draw_surface_ext(argument0, argument1, argument2, 1, 1, 0, c_white, draw_get_alpha())
