/// draw_surface_size(id, x, y, width, height)
/// @arg surface
/// @arg x
/// @arg y
/// @arg width
/// @arg height

if (surface_exists(argument0))
    draw_surface_ext(argument0, argument1, argument2, argument3 / surface_get_width(argument0), argument4 / surface_get_height(argument0), 0, -1, draw_get_alpha())
else
    draw_box(argument1, argument2, argument3, argument4, false, c_black, draw_get_alpha())
