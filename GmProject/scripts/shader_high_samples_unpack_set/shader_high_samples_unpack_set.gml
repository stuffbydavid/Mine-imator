/// shader_high_samples_unpack_set()

function shader_high_samples_unpack_set()
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(render_surface_sample_expo))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(render_surface_sample_dec))
	texture_set_stage(sampler_map[?"uSamplesAlpha"], surface_get_texture(render_surface_sample_alpha))
	render_set_uniform("uSamplesStrength", 255/render_samples)
	render_set_uniform_int("uRenderBackground", render_background)
}
