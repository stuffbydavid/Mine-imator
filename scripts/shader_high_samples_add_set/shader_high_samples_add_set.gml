/// shader_high_samples_add_set(exponent, decimal)
/// @arg exponent
/// @arg decimal

function shader_high_samples_add_set(exponent, decimal)
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(decimal))
}
