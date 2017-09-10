/// texture_sprite(sprite, subimage)
/// @arg sprite
/// @arg subimage

if (texture_lib)
{
	sprite_save_lib(argument0, argument1, temp_image)
	return texture_create(temp_image)
}
else
	return sprite_duplicate(argument0)