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
	
	render_set_uniform("uTAAMatrix", taa_matrix)
	
	render_set_uniform("uSampleIndex", render_sample_current)
	render_set_uniform_int("uAlphaHash", render_alpha_hash)
	
	render_set_uniform_int("uUseNormalMap", dev_mode_skip_tangents ? 0 : 1)
	
	// Set wind
	if (!is_undefined(uniform_map[?"uTime"]) && uniform_map[?"uTime"] > -1)
	{
		render_set_uniform("uTime", app.background_time)
		render_set_uniform("uWindEnable", 0)
		render_set_uniform("uWindTerrain", 1)
		render_set_uniform("uWindSpeed", app.background_wind * app.background_wind_speed)
		render_set_uniform("uWindStrength", app.background_wind_strength * app.setting_wind_enable)
		
		render_set_uniform_vec2("uWindDirection", sin(degtorad(app.background_wind_direction)), cos(degtorad(app.background_wind_direction)))
		render_set_uniform("uWindDirectionalSpeed", app.background_wind * app.background_wind_directional_speed * .1 * app.background_time)
		render_set_uniform("uWindDirectionalStrength", app.background_wind * app.background_wind_directional_strength * app.setting_wind_enable)
	}
	
	// Set fog
	if (!is_undefined(uniform_map[?"uFogShow"]) && uniform_map[?"uFogShow"] > -1)
	{
		var fog = (app.background_fog_show && render_mode != e_render_mode.COLOR);
		render_set_uniform_int("uFogShow", bool_to_float(fog))
		
		render_set_uniform_color("uFogColor", app.background_fog_object_color_final, 1)
		render_set_uniform("uFogDistance", app.background_fog_distance)
		
		render_set_uniform("uFogSize", app.background_fog_size)	
		render_set_uniform("uFogHeight", app.background_fog_height)
	}
	
	// Set camera position
	if (!is_undefined(uniform_map[?"uCameraPosition"]) && uniform_map[?"uCameraPosition"] > -1)
		render_set_uniform_vec3("uCameraPosition", cam_from[X], cam_from[Y], cam_from[Z])
	
	// Block emissive
	if (!is_undefined(uniform_map[?"uDefaultEmissive"]) && uniform_map[?"uDefaultEmissive"] > -1)
		render_set_uniform("uDefaultEmissive", app.project_render_block_emissive)
	
	// Block subsurface scattering
	if (!is_undefined(uniform_map[?"uDefaultSubsurface"]) && uniform_map[?"uDefaultSubsurface"] > -1)
		render_set_uniform("uDefaultSubsurface", app.project_render_block_subsurface)
	
	// Subsurface highlight
	if (!is_undefined(uniform_map[?"uSSSHighlight"]) && uniform_map[?"uSSSHighlight"] > -1)
		render_set_uniform("uSSSHighlight", 1 - app.project_render_subsurface_highlight)
	
	if (!is_undefined(uniform_map[?"uSSSHighlightStrength"]) && uniform_map[?"uSSSHighlightStrength"] > -1)
		render_set_uniform("uSSSHighlightStrength", app.project_render_subsurface_highlight_strength)
	
	// Glint
	if (!is_undefined(uniform_map[?"uGlintEnabled"]) && uniform_map[?"uGlintEnabled"] > -1)
	{
		var tex = mc_res.glint_armor_texture;
		texture_set_stage(sampler_map[?"uGlintTexture"], sprite_get_texture(tex, 0))
		gpu_set_texrepeat_ext(sampler_map[?"uGlintTexture"], true)
		if (platform_get() == e_platform.WINDOWS) // OpenGL bug workaround
			gpu_set_tex_filter_ext(sampler_map[?"uGlintTexture"], true)
		
		render_set_uniform_vec2("uGlintSize", sprite_get_width(tex)*2, sprite_get_height(tex)*2)
		render_set_uniform_vec2("uGlintOffset", app.background_time * (0.000625) * app.project_render_glint_speed, app.background_time * (0.00125) * app.project_render_glint_speed)
		render_set_uniform_int("uGlintEnabled", 1)
		render_set_uniform("uGlintStrength", app.project_render_glint_strength)
		render_set_uniform("uGamma", render_gamma)
	}
	
	// Texture drawing
	render_set_uniform("uMask", bool_to_float(shader_mask))
	
	if (!is_undefined(uniform_map[?"uTextureOffset"]) && uniform_map[?"uTextureOffset"] > -1)
		render_set_uniform_vec2("uTextureOffset", 0, 0)
	
	// Init script
	if (script > -1)
		script_execute(script)
}
