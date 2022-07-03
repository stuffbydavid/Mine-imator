/// shader_high_samples_unpack_set(exponent, decimal, alpha, samples)
/// @arg exponent
/// @arg decimal
/// @arg alpha
/// @arg samples

function shader_high_samples_unpack_set(exponent, decimal, alpha, samples)
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(decimal))
	texture_set_stage(sampler_map[?"uSamplesAlpha"], surface_get_texture(alpha))
	render_set_uniform("uSamplesStrength", 255/samples)
}
