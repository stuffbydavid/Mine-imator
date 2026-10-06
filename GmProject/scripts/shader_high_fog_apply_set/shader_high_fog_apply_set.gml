function shader_high_fog_apply_set(fogbuffer)
{
	texture_set_stage(sampler_handle[e_sampler.FOG_BUFFER], surface_get_texture(fogbuffer))
	render_set_uniform_color(e_uniform.FOG_COLOR, app.env_fog_object_color_final, 1)
	render_set_uniform(e_uniform.BACKGROUND_BRIGHTNESS, app.env_brightness)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}
