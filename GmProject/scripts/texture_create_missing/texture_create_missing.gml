/// @desc Creates a checkerboard texture.

function texture_create_missing(size = 16, render = true, usepage = true)
{
	var surf, newtex;
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		draw_missing(0, 0, size, size)
	}
	surface_reset_target()
	
	newtex = texture_surface(surf, render, usepage)
	surface_free(surf)
	
	return newtex
}
