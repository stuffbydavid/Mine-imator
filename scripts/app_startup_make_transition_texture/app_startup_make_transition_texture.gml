/// app_startup_make_transition_texture(width, height, padding)
/// @arg width
/// @arg height
/// @arg padding

var w, h, wp, hp, padding, surf, tex;
w = argument0
h = argument1
padding = argument2

surf = surface_create(w, h)
surface_set_target(surf)
draw_set_color(c_white)

wp = w-padding * 2
hp = h-padding * 2

for (var t = 0; t < ds_list_size(transition_list); t++)
{
	draw_clear_alpha(c_black, 0)
	for (var xx = 0; xx <= 1; xx += 1/wp)
	{
		draw_line(padding + floor((xx - 1/wp) * wp), 
				  padding + floor((1 - ease(transition_list[|t], xx - 1/wp)) * hp), 
				  padding + floor(xx * wp), 
				  padding + floor((1 - ease(transition_list[|t], xx)) * hp))
	}
	tex[t] = texture_surface(surf)
}

surface_reset_target()
surface_free(surf)

return tex
