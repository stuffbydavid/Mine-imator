/// shader_high_samples_unpack_set()

function shader_high_samples_unpack_set()
{
	texture_set_stage(sampler_map[?"uSamples"], surface_get_texture(render_surface_samples))
	render_set_uniform("uSamplesStrength", 1/render_samples)
	render_set_uniform_int("uRenderBackground", render_background)
}
