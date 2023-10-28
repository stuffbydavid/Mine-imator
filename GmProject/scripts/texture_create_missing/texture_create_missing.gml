/// texture_create_missing([size])
/// @arg [size]
/// @desc Creates a checkerboard texture.

function texture_create_missing(size = 16)
{
	var surf, newtex;
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		draw_missing(0, 0, size, size)
	}
	surface_reset_target()
	
	newtex = texture_surface(surf)
	surface_free(surf)
	
	return newtex
}
