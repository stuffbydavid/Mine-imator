/// texture_sprite(sprite)
/// @arg sprite

if (texture_lib)
{
	sprite_save_lib(argument0, 0, temp_image)
	return texture_create(temp_image)
}
else
	return sprite_duplicate(argument0)