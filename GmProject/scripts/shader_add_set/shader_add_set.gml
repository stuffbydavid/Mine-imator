/// @arg surface
/// @arg amount
/// @arg [color]
/// @arg [power]
/// @arg [tentfilter]
/// @arg [affectalpha]

function shader_add_set(surf, amount, color = c_white, pow = 1, tentfilter = false, affectalpha = false)
{
	texture_set_stage(sampler_map[?"uAddTexture"], surface_get_texture(surf))
	gpu_set_texfilter_ext(sampler_map[?"uAddTexture"], false)
	
	render_set_uniform("uAmount", amount)
	render_set_uniform_color("uBlendColor", color, 1)
	render_set_uniform("uPower", pow)

	render_set_uniform_int("uTentFilter", tentfilter ? 1 : 0)
	if (tentfilter)
	{
		render_set_uniform_vec2("uAddTexelSize", 1 / surface_get_width(surf), 1 / surface_get_height(surf))
		gpu_set_texfilter_ext(sampler_map[?"uAddTexture"], true)
	}

	render_set_uniform_int("uAffectAlpha", affectalpha ? 1 : 0)
}
