/// shader_add_set(texture, amount, [color], [power], [tentfilter])
/// @arg texture
/// @arg amount
/// @arg [color]
/// @arg [power]
/// @arg [tentfilter]

function shader_add_set()
{
	texture_set_stage(sampler_map[?"uAddTexture"], surface_get_texture(argument[0]))
	gpu_set_texfilter_ext(sampler_map[?"uAddTexture"], false)
	
	render_set_uniform("uAmount", argument[1])
	
	if (argument_count > 2)
		render_set_uniform_color("uBlendColor", argument[2], 1)
	else
		render_set_uniform_color("uBlendColor", c_white, 1)
	
	if (argument_count > 3)
		render_set_uniform("uPower", argument[3])
	else
		render_set_uniform("uPower", 1)

	var tentfilter = argument_count > 4 && argument[4];
	render_set_uniform_int("uTentFilter", tentfilter ? 1 : 0)
	if (tentfilter)
	{
		render_set_uniform_vec2("uAddTexelSize", 1 / surface_get_width(argument[0]), 1 / surface_get_height(argument[0]))
		gpu_set_texfilter_ext(sampler_map[?"uAddTexture"], true)
	}
}
