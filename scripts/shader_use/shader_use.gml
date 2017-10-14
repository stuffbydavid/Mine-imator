/// shader_use()
/// @desc Sets the shader and defines the uniforms

shader_set(shader)

// Default color
shader_blend_color = c_white
shader_blend_alpha = 1
render_set_uniform_color("uBlendColor", c_white, 1)

// Set wind
if (uniform_map[?"uTime"] > -1)
{
	render_set_uniform("uTime", current_step)
	render_set_uniform("uWindEnable", false)
	render_set_uniform("uWindTerrain", true)
	render_set_uniform("uWindSpeed", app.background_wind * app.background_wind_speed)
	render_set_uniform("uWindStrength", app.background_wind_strength)
}

// Set fog
if (uniform_map[?"uFogShow"] > -1)
{
	var fog = (render_lights && app.background_fog_show);
	render_set_uniform_int("uFogShow", bool_to_float(fog))

	if (fog)
	{
		render_set_uniform_color("uFogColor", app.background_fog_color_final, 1)
		render_set_uniform("uFogDistance", app.background_fog_distance)
		render_set_uniform("uFogSize", app.background_fog_size)
		render_set_uniform("uFogHeight", app.background_fog_height)
	}
}

// Init script
if (script > -1)
	script_execute(script)
		
/*switch (render_mode)
{
	case e_render_mode.CLICK:
		shader_replace_color = shader_tl
		shader_replace_set()
		break
	
	case e_render_mode.SELECT:
	case e_render_mode.PREVIEW: shader_blend_set() break
	case e_render_mode.COLOR_FOG: shader_color_fog_set() break
	case e_render_mode.COLOR_FOG_LIGHTS: shader_color_fog_lights_set() break
	
	case e_render_mode.ALPHA_FIX:
		shader_blend_color = c_black
		shader_blend_set()
		break
		
	case e_render_mode.ALPHA_TEST:
		shader_blend_color = c_black
		shader_alpha_test_set()
		break
	
	// High quality
	case e_render_mode.HIGH_SSAO_DEPTH_NORMAL: shader_high_ssao_depth_normal_set() break
	case e_render_mode.HIGH_DOF_DEPTH:
	case e_render_mode.HIGH_LIGHT_SUN_DEPTH:
	case e_render_mode.HIGH_LIGHT_SPOT_DEPTH: shader_depth_set() break
	case e_render_mode.HIGH_LIGHT_POINT_DEPTH: shader_depth_point_set() break
	case e_render_mode.HIGH_LIGHT_SUN: shader_high_light_sun_set() break
	case e_render_mode.HIGH_LIGHT_SPOT: shader_high_light_spot_set() break
	case e_render_mode.HIGH_LIGHT_POINT: shader_high_light_point_set() break
	case e_render_mode.HIGH_LIGHT_NIGHT: shader_high_light_night_set() break
	case e_render_mode.HIGH_FOG: shader_high_fog_set() break
}*/
