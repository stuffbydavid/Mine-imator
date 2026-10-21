/// @arg surface
/// @arg amount
/// @arg [color]
/// @arg [power]
/// @arg [tentfilter]
/// @arg [affectalpha]

function shader_add_set(surf, amount, color = c_white, pow = 1, tentfilter = false, affectalpha = false)
{
	texture_set_stage(sampler_handle[e_sampler.ADD_TEXTURE], surface_get_texture(surf))
	gpu_set_texfilter_ext(sampler_handle[e_sampler.ADD_TEXTURE], false)
	
	render_set_uniform(e_uniform.AMOUNT, amount)
	render_set_uniform_color(e_uniform.BLEND_COLOR, color, 1)
	render_set_uniform(e_uniform.POWER, pow)

	render_set_uniform_int(e_uniform.TENT_FILTER, tentfilter ? 1 : 0)
	if (tentfilter)
	{
		render_set_uniform_vec2(e_uniform.ADD_TEXEL_SIZE, 1 / surface_get_width(surf), 1 / surface_get_height(surf))
		gpu_set_texfilter_ext(sampler_handle[e_sampler.ADD_TEXTURE], true)
	}

	render_set_uniform_int(e_uniform.AFFECT_ALPHA, affectalpha ? 1 : 0)
}
