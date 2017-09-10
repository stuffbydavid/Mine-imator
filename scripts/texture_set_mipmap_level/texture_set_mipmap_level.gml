/// texture_set_mipmap_level(level)
/// @arg level

if (texture_lib)
	external_call(lib_texture_set_mipmap_level, argument0)
else
	gpu_set_tex_mip_bias(-argument0)