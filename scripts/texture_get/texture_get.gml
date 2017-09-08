/// texture_get(texture)
/// @arg texture

if (!shader_texture_surface)
{
	if (!sprite_exists(argument0))
		return -1
	
	return sprite_get_texture(argument0, 0)
}
else
{
	/*if (!surface_exists(argument0))
		return -1
	
	return surface_get_texture(argument0)*/
}