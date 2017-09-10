/// shader_set_texture(sampler, texture)
/// @arg sampler
/// @arg texture

var sampler, tex;
sampler = argument0
tex = argument1

gpu_set_tex_filter_ext(sampler, shader_texture_filter_linear)
gpu_set_tex_mip_enable(shader_texture_filter_mipmap)
gpu_set_tex_mip_filter_ext(sampler, test(shader_texture_filter_mipmap, tf_linear, tf_point))

// GM surface
if (shader_texture_surface)
{
	if (surface_exists(tex))
		texture_set_stage(sampler, surface_get_texture(tex))
	else
		texture_set_stage(sampler, -1)
}

// Library texture
else if (texture_lib)
{
	external_call(lib_texture_set_filtering, sampler, shader_texture_filter_linear, shader_texture_filter_mipmap)
	external_call(lib_texture_set_stage, sampler, tex)
}

// GM sprite
else
{
	if (sprite_exists(tex))
		texture_set_stage(sampler, sprite_get_texture(tex, 0))
	else
		texture_set_stage(sampler, -1)
}