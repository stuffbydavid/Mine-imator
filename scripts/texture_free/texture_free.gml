/// texture_free(texture)
/// @arg texture

if (texture_lib)
	return external_call(lib_texture_free, argument0)
else
	return sprite_delete(argument0)