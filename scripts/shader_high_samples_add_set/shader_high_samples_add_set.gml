/// shader_high_samples_add_set(exponent, decimal, alpha, sample)
/// @arg exponent
/// @arg decimal
/// @arg alpha
/// @arg sample

function shader_high_samples_add_set(exponent, decimal, alpha, sample)
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(decimal))
	texture_set_stage(sampler_map[?"uSamplesAlpha"], surface_get_texture(alpha))
	texture_set_stage(sampler_map[?"uSample"], surface_get_texture(sample))
}
