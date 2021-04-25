/// surface_duplicate(surf)
/// @arg surf

function surface_duplicate(surf)
{
	var newsurf;
	
	if (surface_exists(surf))
		newsurf = surface_create(surface_get_width(surf), surface_get_height(surf))
	else
		newsurf = surface_create(32, 32)
	
	surface_set_target(newsurf)
	{
		draw_clear_alpha(c_black, 1)
		
		if (!surface_exists(surf))
			draw_missing(0, 0, 32, 32)
	}
	surface_reset_target()
	
	if (surface_exists(surf))
		surface_copy(newsurf, 0, 0, surf)
	
	return newsurf
}