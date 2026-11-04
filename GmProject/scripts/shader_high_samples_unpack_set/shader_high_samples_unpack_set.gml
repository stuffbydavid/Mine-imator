function shader_high_samples_unpack_set()
{
	texture_set_stage(sampler_handle[e_sampler.SAMPLES], surface_get_texture(render_surface_samples))
	render_set_uniform(e_uniform.SAMPLES_STRENGTH, 1/render_samples)
	render_set_uniform_int(e_uniform.RENDER_BACKGROUND, render_background)
}
