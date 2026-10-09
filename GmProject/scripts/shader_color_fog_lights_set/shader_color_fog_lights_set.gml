function shader_color_fog_lights_set()
{
	render_set_uniform_int(e_uniform.IS_GROUND, 0)
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	
	// Colors
	render_set_uniform_int(e_uniform.COLORS_EXT, 0)
	
	// Lights
	render_set_uniform_vec3(e_uniform.SUN_DIRECTION, app.env_sun_direction[X], app.env_sun_direction[Y], app.env_sun_direction[Z])
	render_set_uniform_int(e_uniform.LIGHT_AMOUNT, app.env_light_amount)
	render_set_uniform(e_uniform.LIGHT_DATA, app.env_light_data)
	render_set_uniform_color(e_uniform.AMBIENT_COLOR, app.env_ambient_color_final, 1)
	render_set_uniform(e_uniform.EMISSIVE, 0)
	
	render_set_uniform_color(e_uniform.FALLBACK_COLOR, render_background ? app.env_sky_color_final : c_black, 1)
	render_set_uniform_int(e_uniform.TONEMAPPER, render_tonemapper)
	render_set_uniform(e_uniform.EXPOSURE, render_exposure)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}
