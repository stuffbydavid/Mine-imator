/// texture_surface(surface)
/// @arg surface

if (texture_lib)
{
	surface_save_lib(argument0, temp_image)
	return texture_create(temp_image)
}
else
	return sprite_create_from_surface(argument0, 0, 0, surface_get_width(argument0), surface_get_height(argument0), false, false, 0, 0)