/// @desc Sets the shader and defines the common uniforms.

function shader_use()
{
	shader_set(shader)
	
	shader_texture_binding = null
	
	// Default color
	shader_blend_color = c_white
	shader_blend_alpha = 1
	render_set_uniform_color(e_uniform.BLEND_COLOR, c_white, 1)
	
	render_set_uniform(e_uniform.METALLIC, 0)
	render_set_uniform(e_uniform.ROUGHNESS, 1)
	
	render_set_uniform(e_uniform.AA_MATRIX, aa_matrix)
	render_set_uniform(e_uniform.TAA_MATRIX, aa_matrix)
	
	render_set_uniform(e_uniform.SAMPLE_INDEX, render_sample_current)
	render_set_uniform_int(e_uniform.ALPHA_HASH, render_alpha_hash)
	
	render_set_uniform_int(e_uniform.HAS_NORMAL_MAP, 0)
	
	render_set_uniform(e_uniform.GAMMA, render_gamma)
	
	// Set wind
	if (!is_undefined(uniform_handle[e_uniform.TIME]) && uniform_handle[e_uniform.TIME] > -1)
	{
		render_set_uniform(e_uniform.TIME, app.env_time)
		render_set_uniform(e_uniform.WIND_ENABLE, 0)
		render_set_uniform(e_uniform.WIND_TERRAIN, 1)
		render_set_uniform(e_uniform.WIND_SPEED, app.env_wind * app.env_wind_speed)
		render_set_uniform(e_uniform.WIND_STRENGTH, app.env_wind_strength * app.setting_wind_enable)
		
		render_set_uniform_vec2(e_uniform.WIND_DIRECTION, sin(degtorad(app.env_wind_direction)), cos(degtorad(app.env_wind_direction)))
		render_set_uniform(e_uniform.WIND_DIRECTIONAL_SPEED, app.env_wind * app.env_wind_directional_speed * .1 * app.env_time)
		render_set_uniform(e_uniform.WIND_DIRECTIONAL_STRENGTH, app.env_wind * app.env_wind_directional_strength * app.setting_wind_enable)
	}

	if (!is_undefined(uniform_handle[e_uniform.WATER_MATERIAL_TIME]) && uniform_handle[e_uniform.WATER_MATERIAL_TIME] > -1)
	{
		render_set_uniform(e_uniform.WATER_MATERIAL_TIME, app.env_time * app.project_render_water_wave_speed)
		render_set_uniform(e_uniform.WATER_MATERIAL_STRENGTH, app.project_render_water_wave_strength)
		render_set_uniform(e_uniform.WATER_MATERIAL_SCALE, app.project_render_water_wave_scale)
		render_set_uniform_int(e_uniform.WATER_MATERIAL_OCTAVES, app.project_render_water_wave_detail)
	}
	
	// Set fog
	if (!is_undefined(uniform_handle[e_uniform.FOG_SHOW]) && uniform_handle[e_uniform.FOG_SHOW] > -1)
	{
		var fog = (app.env_fog_show && (render_mode != e_render_mode.COLOR || render_fog_combined));
		render_set_uniform_int(e_uniform.FOG_SHOW, bool_to_float(fog))
		render_set_uniform_int(e_uniform.FOG_PASS, render_fog_combined && render_mode = e_render_mode.COLOR)
		
		render_set_uniform_color(e_uniform.FOG_COLOR, app.env_fog_object_color_final, 1)
		render_set_uniform(e_uniform.FOG_DISTANCE, app.env_fog_distance)
		
		render_set_uniform(e_uniform.FOG_SIZE, app.env_fog_size)
		render_set_uniform(e_uniform.FOG_HEIGHT, app.env_fog_height)
	}
	
	// Set camera position
	if (!is_undefined(uniform_handle[e_uniform.CAMERA_POSITION]) && uniform_handle[e_uniform.CAMERA_POSITION] > -1)
		render_set_uniform_vec3(e_uniform.CAMERA_POSITION, cam_from[X], cam_from[Y], cam_from[Z])
	
	// Block emissive
	if (!is_undefined(uniform_handle[e_uniform.DEFAULT_EMISSIVE]) && uniform_handle[e_uniform.DEFAULT_EMISSIVE] > -1)
		render_set_uniform(e_uniform.DEFAULT_EMISSIVE, app.project_render_block_emissive)
	
	// Block subsurface scattering
	if (!is_undefined(uniform_handle[e_uniform.DEFAULT_SUBSURFACE]) && uniform_handle[e_uniform.DEFAULT_SUBSURFACE] > -1)
		render_set_uniform(e_uniform.DEFAULT_SUBSURFACE, app.project_render_block_subsurface)
	
	// Subsurface backlight
	if (!is_undefined(uniform_handle[e_uniform.SSS_BACKLIGHT_SPREAD]) && uniform_handle[e_uniform.SSS_BACKLIGHT_SPREAD] > -1)
		render_set_uniform(e_uniform.SSS_BACKLIGHT_SPREAD, 1 - app.project_render_subsurface_backlight_spread)
	
	if (!is_undefined(uniform_handle[e_uniform.SSS_BACKLIGHT_STRENGTH]) && uniform_handle[e_uniform.SSS_BACKLIGHT_STRENGTH] > -1)
		render_set_uniform(e_uniform.SSS_BACKLIGHT_STRENGTH, app.project_render_subsurface_backlight_strength)

	if (!is_undefined(uniform_handle[e_uniform.SSS_BRIGHT_BACKLIGHT]) && uniform_handle[e_uniform.SSS_BRIGHT_BACKLIGHT] > -1)
		render_set_uniform_int(e_uniform.SSS_BRIGHT_BACKLIGHT, app.project_render_subsurface_bright_backlight)
	
	// Glint
	render_set_uniform_int(e_uniform.GLINT_PASS, render_glint)
	
	if (!is_undefined(uniform_handle[e_uniform.GLINT_ENABLED]) && uniform_handle[e_uniform.GLINT_ENABLED] > -1 &&
		(render_mode != e_render_mode.G_BUFFERS || render_glint))
	{
		var res = res_eval(project_pack_res);
		if (res.glint_armor_texture = null)
			res = mc_res
		
		var tex = res.glint_armor_texture;
		texture_set_stage(sampler_handle[e_sampler.GLINT_TEXTURE], sprite_get_texture(tex, 0))
		gpu_set_texrepeat_ext(sampler_handle[e_sampler.GLINT_TEXTURE], true)
		gpu_set_tex_filter_ext(sampler_handle[e_sampler.GLINT_TEXTURE], true)
		
		render_set_uniform_vec2(e_uniform.GLINT_SIZE, sprite_get_width(tex)*2, sprite_get_height(tex)*2)
		render_set_uniform_vec2(e_uniform.GLINT_OFFSET, app.env_time * (0.000625) * app.project_render_glint_speed, app.env_time * (0.00125) * app.project_render_glint_speed)
		render_set_uniform_int(e_uniform.GLINT_ENABLED, 1)
		render_set_uniform(e_uniform.GLINT_STRENGTH, app.project_render_glint_strength)
	}
	
	// Texture drawing
	render_set_uniform(e_uniform.MASK, bool_to_float(shader_mask))
	
	if (!is_undefined(uniform_handle[e_uniform.TEXTURE_OFFSET]) && uniform_handle[e_uniform.TEXTURE_OFFSET] > -1)
		render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, 0, 0)
	
	// Tone mapping in quick mode
	if (renderer_current = e_renderer.QUICK && render_mode = e_render_mode.COLOR_FOG)
		shader_tonemap_set()

	// Init script
	if (script > -1)
		script_execute(script)
}
