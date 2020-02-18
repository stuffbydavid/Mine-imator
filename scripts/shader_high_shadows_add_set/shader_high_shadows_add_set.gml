/// shader_high_shadows_add_set(exponent, decimal)
/// @arg exponent
/// @arg decimal

texture_set_stage(sampler_map[?"uShadowExp"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uShadowDec"], surface_get_texture(argument1))
