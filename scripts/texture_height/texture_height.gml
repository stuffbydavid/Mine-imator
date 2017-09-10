/// texture_height(texture)
/// @arg texture

if (texture_lib)
	return external_call(lib_texture_height, argument0)
else
	return sprite_get_height(argument0)