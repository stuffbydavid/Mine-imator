/// shader_use()
/// @desc Sets the shader and defines the common uniforms

function shader_use()
{
	shader_set(shader)
	
	// Default color
	shader_blend_color = c_white
	shader_blend_alpha = 1
	render_set_uniform_color("uBlendColor", c_white, 1)
	
	render_set_uniform("uMetallic", 0)
	render_set_uniform("uRoughness", 1)
	
	// Set wind
	if (!is_undefined(uniform_map[?"uTime"]) && uniform_map[?"uTime"] > -1)
	{
		render_set_uniform("uTime", app.background_time)
		render_set_uniform("uWindEnable", 0)
		render_set_uniform("uWindTerrain", 1)
		render_set_uniform("uWindSpeed", app.background_wind * app.background_wind_speed)
		render_set_uniform("uWindStrength", app.background_wind_strength * app.setting_wind_enable)
		
		render_set_uniform("uWindDirection", degtorad(app.background_wind_direction)) 
		render_set_uniform("uWindDirectionalSpeed", app.background_wind * app.background_wind_directional_speed * .1) 
		render_set_uniform("uWindDirectionalStrength", app.background_wind * app.background_wind_directional_strength * app.setting_wind_enable) 
	}
	
	// Set fog
	if (!is_undefined(uniform_map[?"uFogShow"]) && uniform_map[?"uFogShow"] > -1)
	{
		var fog = (render_fog && app.background_fog_show && render_mode != e_render_mode.COLOR);
		render_set_uniform_int("uFogShow", bool_to_float(fog))
		
		render_set_uniform_color("uFogColor", app.background_fog_object_color_final, 1)
		render_set_uniform("uFogDistance", app.background_fog_distance)
			
		if (app.background_twilight)
			render_set_uniform("uFogSize", app.background_fog_size + (app.background_fog_size * 3 * max(app.background_sunrise_alpha, app.background_sunset_alpha)))
		else
			render_set_uniform("uFogSize", app.background_fog_size)
			
		render_set_uniform("uFogHeight", app.background_fog_height)
	}
	
	// Set camera position
	if (!is_undefined(uniform_map[?"uCameraPosition"]) && uniform_map[?"uCameraPosition"] > -1)
		render_set_uniform_vec3("uCameraPosition", cam_from[X], cam_from[Y], cam_from[Z])
	
	// Block brightness
	if (!is_undefined(uniform_map[?"uBlockBrightness"]) && uniform_map[?"uBlockBrightness"] > -1)
		render_set_uniform("uBlockBrightness", app.project_render_block_brightness)
	
	// Block brightness threshold
	if (!is_undefined(uniform_map[?"uGlowThreshold"]) && uniform_map[?"uGlowThreshold"] > -1)
		render_set_uniform("uGlowThreshold", app.project_render_block_glow_threshold)
	
	// Block subsurface scattering
	if (!is_undefined(uniform_map[?"uBlockSSS"]) && uniform_map[?"uBlockSSS"] > -1)
		render_set_uniform("uBlockSSS", app.project_render_block_subsurface)
	
	// Texture drawing
	render_set_uniform("uMask", bool_to_float(shader_mask))
	
	// Block glow
	render_set_uniform_int("uBlockGlow", app.project_render_block_glow)
	
	// Init script
	if (script > -1)
		script_execute(script)
}
