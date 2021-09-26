/// texture_create_fill(color, [size])
/// @arg color
/// @arg [size]
/// @desc Creates a texture with a single color.

function texture_create_fill(color, size)
{
	var surf, newtex;
	
	if (size = undefined)
		size = 16
	
	surf = surface_create(size, size)
	surface_set_target(surf)
	{
		draw_clear(color)
	}
	surface_reset_target()
	
	newtex = texture_surface(surf)
	surface_free(surf)
	
	return newtex
}
