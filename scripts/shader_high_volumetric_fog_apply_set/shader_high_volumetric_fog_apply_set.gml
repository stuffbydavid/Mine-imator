/// shader_high_volumetric_fog_apply_set(exponent, decimal, samples)
/// @arg exponent
/// @arg decimal
/// @arg samples

function shader_high_volumetric_fog_apply_set(exponent, decimal, samples)
{
	texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(exponent))
	texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(decimal))
	render_set_uniform("uSamplesStrength", 255/samples)
	
	render_set_uniform_int("uFogAmbience", app.background_volumetric_fog_ambience)
	
	render_set_uniform_color("uColor", app.background_volumetric_fog_color, 1)
	render_set_uniform_color("uSunColor", app.background_sunlight_color_final, 1)
	render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
}
