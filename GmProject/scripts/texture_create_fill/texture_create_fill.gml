/// @desc Creates a texture with a single color.

function texture_create_fill(color, size = 16, usepage = true)
{
	var surf, newtex;
	
	surf = surface_create(size, size)
	surface_clear(surf, color)
	
	newtex = texture_surface(surf, true, usepage)
	surface_free(surf)
	
	return newtex
}
