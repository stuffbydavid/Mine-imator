/// shader_add_set(texture, amount, [color], [power])
/// @arg texture
/// @arg amount
/// @arg [color]
/// @arg [power]

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