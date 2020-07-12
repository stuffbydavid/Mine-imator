/// shader_high_samples_unpack_set(exponent, decimal, samples)
/// @arg exponent
/// @arg decimal
/// @arg samples

texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(argument1))
render_set_uniform("uSamplesStrength", 255/(argument2 + 1))