/// shader_high_shadows_add_set(exponent, decimal)
/// @arg exponent
/// @arg decimal

function shader_high_shadows_add_set(exponent, decimal)
{
	texture_set_stage(sampler_map[?"uShadowExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uShadowDec"], surface_get_texture(decimal))
}
