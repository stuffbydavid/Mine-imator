/// surface_duplicate(surf, [scale])
/// @arg surf
/// @arg [scale]

function surface_duplicate(surf)
{
	var newsurf, scale;
	scale = (argument_count > 1 ? argument[1] : 1)
	
	if (surface_exists(surf))
		newsurf = surface_create(surface_get_width(surf) * scale, surface_get_height(surf) * scale)
	else
		newsurf = surface_create(32, 32)
	
	surface_set_target(newsurf)
	{
		draw_clear_alpha(c_black, 1)
		
		if (!surface_exists(surf))
			draw_missing(0, 0, 32, 32)
		
		if (surface_exists(surf))
			draw_surface_ext(surf, 0, 0, scale, scale, 0, c_white, 1)
	}
	surface_reset_target()
	
	return newsurf
}