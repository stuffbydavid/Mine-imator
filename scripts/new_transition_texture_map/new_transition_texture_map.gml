/// new_transition_texture_map(width, height, padding, center)
/// @arg width
/// @arg height
/// @arg padding
/// @arg center

function new_transition_texture_map(w, h, padding, center)
{
	var wp, hp, surf, surfaa, map, quality, aa;
	map = ds_map_create()
	aa = 4
	quality = w * aa
	
	surf = surface_create(w * aa, h * aa)
	surfaa = surface_create(w, h)
	
	wp = (w * aa) - (padding * 2 * aa)
	hp = (h * aa) - (padding * 2 * aa)
	
	draw_set_color(c_white)
	
	for (var t = 0; t < ds_list_size(transition_list); t++)
	{
		// Draw transition at double res.
		surface_set_target(surf)
		{
			draw_clear_alpha(c_black, 0)
			for (var xx = 0; xx <= 1; xx += 1/quality)
			{
				draw_line_width((padding * aa) + ((xx - 1/wp) * wp), 
							(padding * aa) + ((1 - ease(transition_list[|t], xx - 1 / wp)) * hp), 
							(padding * aa) + (xx * wp), 
							(padding * aa) + ((1 - ease(transition_list[|t], xx)) * hp), (2 * aa) + 1)
			}
		
		}
		surface_reset_target()
		
		// Copy to smaller surface and filter
		gpu_set_tex_filter(true)
		surface_set_target(surfaa)
		{
			draw_clear_alpha(c_black, 0)
			draw_surface_ext(surf, 0, 0, 1/aa, 1/aa, 0, c_white, 1)
		}
		surface_reset_target()
		gpu_set_tex_filter(false)
		
		map[?transition_list[|t]] = texture_surface(surfaa)
		
		if (center)
			sprite_set_offset(map[?transition_list[|t]], w/2, h/2)
	}
	
	surface_free(surf)
	surface_free(surfaa)
	
	return map
}
