/// shader_color_fog_lights_set()

function shader_color_fog_lights_set()
{
	render_set_uniform_int("uIsGround", 0)
	render_set_uniform_int("uIsSky", 0)
	
	// Colors
	render_set_uniform_int("uColorsExt", 0)
	
	// Lights
	render_set_uniform_vec3("uSunDirection", app.background_sun_direction[X], app.background_sun_direction[Y], app.background_sun_direction[Z])
	render_set_uniform_int("uLightAmount", app.background_light_amount)
	render_set_uniform("uLightData", app.background_light_data)
	render_set_uniform_color("uAmbientColor", app.background_ambient_color_final, 1)
	render_set_uniform("uEmissive", 0)
	
	render_set_uniform_color("uFallbackColor", render_background ? app.background_sky_color_final : c_black, 1)
	render_set_uniform_int("uGammaCorrect", app.project_render_gamma_correct)
}
