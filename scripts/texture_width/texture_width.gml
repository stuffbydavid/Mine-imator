/// texture_width(texture)
/// @arg texture

if (texture_lib)
	return external_call(lib_texture_width, argument0)
else
	return sprite_get_width(argument0)