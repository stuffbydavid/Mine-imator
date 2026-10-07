/// @desc Resets render values after finishing rendering timelines.

function render_world_tl_reset()
{
	matrix_world_reset()
	render_set_culling(true)
	
	shader_texture_filter_linear = false
	shader_texture_filter_mipmap = false
	shader_texture_binding = null
	
	shader_texture_width = 0
	shader_texture_height = 0
	
	shader_blend_color = c_white
	shader_blend_alpha = 1
	
	render_set_uniform_color(e_uniform.BLEND_COLOR, shader_blend_color, shader_blend_alpha)
	render_set_uniform_color(e_uniform.REPLACE_COLOR, render_mode = e_render_mode.COLOR ? c_white : c_black, 1)
	
	if (!render_alpha_hash_force)
	{
		render_alpha_hash = render_alpha_hash_allowed && app.project_render_alpha_mode
		render_set_uniform_int(e_uniform.ALPHA_HASH, render_alpha_hash)
	}
	
	// Mix color
	shader_uniform_color_ext = 0
	shader_uniform_rgb_add = c_black
	shader_uniform_hsb_add = c_black
	shader_uniform_rgb_sub = c_black
	shader_uniform_hsb_sub = c_black
	shader_uniform_hsb_mul = c_white
	shader_uniform_mix_color = c_black
	shader_uniform_mix_percent = 0
	
	render_set_uniform_int(e_uniform.COLORS_EXT, shader_uniform_color_ext)
	render_set_uniform_color(e_uniform.RGB_ADD, shader_uniform_rgb_add, 1)
	render_set_uniform_color(e_uniform.HSB_ADD, shader_uniform_hsb_add, 1)
	render_set_uniform_color(e_uniform.RGB_SUB, shader_uniform_rgb_sub, 1)
	render_set_uniform_color(e_uniform.HSB_SUB, shader_uniform_hsb_sub, 1)
	render_set_uniform_color(e_uniform.HSB_MUL, shader_uniform_hsb_mul, 1)
	render_set_uniform_color(e_uniform.MIX_COLOR, shader_uniform_mix_color, shader_uniform_mix_percent)
	
	render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, 0, 0)
	render_set_uniform_int(e_uniform.MATERIAL_FORMAT, e_material.FORMAT_NONE)
	
	// Emissive
	shader_uniform_emissive = 0
	render_set_uniform(e_uniform.EMISSIVE, shader_uniform_emissive)
	
	// Metallic
	shader_uniform_metallic = 0
	render_set_uniform(e_uniform.METALLIC, 0)
	
	// Roughness
	shader_uniform_roughness = 0
	render_set_uniform(e_uniform.ROUGHNESS, shader_uniform_roughness)
	
	// Wind
	shader_uniform_wind = false
	shader_uniform_wind_terrain = false
	render_set_uniform(e_uniform.WIND_ENABLE, shader_uniform_wind)
	render_set_uniform(e_uniform.WIND_TERRAIN, shader_uniform_wind_terrain)
	
	// Fog
	shader_uniform_fog = (app.env_fog_show && (render_mode != e_render_mode.COLOR || render_fog_combined))
	render_set_uniform_int(e_uniform.FOG_SHOW, shader_uniform_fog)
	render_set_uniform(e_uniform.SSAO, 1)
	
	// SSS
	shader_uniform_sss = 0
	shader_uniform_sss_red = 1
	shader_uniform_sss_green = 1
	shader_uniform_sss_blue = 1
	shader_uniform_sss_color = c_white
	render_set_uniform(e_uniform.SSS, shader_uniform_sss)
	render_set_uniform_vec3(e_uniform.SSS_RADIUS, shader_uniform_sss_red,
										  shader_uniform_sss_green,
										  shader_uniform_sss_blue)
	render_set_uniform_color(e_uniform.SSS_COLOR, shader_uniform_sss_color, 1.0)
	
	// Wind
	shader_uniform_wind_strength = app.env_wind_strength * app.setting_wind_enable
	
	// Glow
	shader_uniform_glow = false
	shader_uniform_glow_texture = false
	shader_uniform_glow_color = c_white
	render_set_uniform_int(e_uniform.ONLY_RENDER_GLOW, 0)
	
	// Glint
	render_set_uniform_int(e_uniform.GLINT_ENABLED, 0)
	
	// Depth during placement
	if (render_mode = e_render_mode.PLACE)
		render_set_uniform(e_uniform.GM_DEPTH, bool_to_float(!is_cpp()))
	
	render_blend_prev = null
	render_alpha_prev = null
}
