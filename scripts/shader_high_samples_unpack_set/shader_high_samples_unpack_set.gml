/// shader_high_samples_unpack_set(exponent, decimal, samples)
/// @arg exponent
/// @arg decimal
/// @arg samples

function shader_high_samples_unpack_set(exponent, decimal, samples)
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(decimal))
	render_set_uniform("uSamplesStrength", 255/samples)
}
