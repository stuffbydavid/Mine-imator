/// @desc Creates a texture with a single color.

function texture_create_fill(color, size = 16, usepage = true)
{
	var surf, newtex;
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		draw_clear(color)
	}
	surface_reset_target()
	
	newtex = texture_surface(surf, true, usepage)
	surface_free(surf)
	
	return newtex
}
