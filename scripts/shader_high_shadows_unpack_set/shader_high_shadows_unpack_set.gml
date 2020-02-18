/// shader_high_shadows_unpack_set(exponent, decimal)
/// @arg exponent
/// @arg decimal

texture_set_stage(sampler_map[?"uShadowExp"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uShadowDec"], surface_get_texture(argument1))
render_set_uniform("uShadowsStrength", 255/render_samples)