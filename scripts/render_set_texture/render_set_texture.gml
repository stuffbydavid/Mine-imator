/// render_set_texture(texture)
/// @arg texture
/// @desc Sets the texture of the currently selected texture.

var tex, sampler;
tex = argument0
sampler = render_shader_obj.sampler_map[?"uTexture"]

if (sampler < 0)
	return 0

if (!texture_lib)
{
	gpu_set_tex_filter_ext(sampler, shader_texture_filter_linear)
	gpu_set_tex_mip_enable(test(shader_texture_filter_mipmap, mip_on, mip_off))
	gpu_set_tex_mip_filter_ext(sampler, test(shader_texture_filter_mipmap, tf_linear, tf_point))
}
else
	texture_set_stage(sampler, 0) // Clear GM texture

// GM surface
if (shader_texture_surface)
{
	if (surface_exists(tex))
		texture_set_stage(sampler, surface_get_texture(tex))
	else
		texture_set_stage(sampler, 0)
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
		texture_set_stage(sampler, 0)
}