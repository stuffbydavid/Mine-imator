/// texture_duplicate(texture)
/// @arg texture

if (texture_lib)
{
	texture_export(argument0, temp_image)
	return texture_create(temp_image)
}
else
	return sprite_duplicate(argument0)