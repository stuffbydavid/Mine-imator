/// texture_surface(surface)
/// @arg surface

function texture_surface(surf)
{
	return sprite_create_from_surface(surf, 0, 0, surface_get_width(surf), surface_get_height(surf), false, false, 0, 0)
}
