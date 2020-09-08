/// shader_high_volumetric_fog_apply_set(exponent, decimal, samples)
/// @arg exponent
/// @arg decimal
/// @arg samples

texture_set_stage(sampler_map[?"uSamplesExp"], surface_get_texture(argument0))
texture_set_stage(sampler_map[?"uSamplesDec"], surface_get_texture(argument1))
render_set_uniform("uSamplesStrength", 255/(argument2 + 1))

render_set_uniform_int("uRaysOnly", app.background_volumetric_fog_rays)

render_set_uniform_color("uColor", app.background_volumetric_fog_color, 1)
render_set_uniform_color("uSunColor", app.background_sunlight_color_final, 1)
render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
render_set_uniform("uFogBrightness", app.background_volumetric_fog_brightness)
