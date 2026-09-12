/// render_world_tl_reset()
/// @desc Resets render values after finishing rendering timelines

function render_world_tl_reset()
{
	matrix_world_reset()
	render_set_culling(true)
	shader_texture_filter_linear = false
	shader_texture_filter_mipmap = false
	
	shader_texture_width = 0
	shader_texture_height = 0
	
	shader_blend_color = c_white
	shader_blend_alpha = 1
	
	render_set_uniform_color("uBlendColor", shader_blend_color, shader_blend_alpha)
	
	// Mix color
	shader_uniform_color_ext = 0
	shader_uniform_rgb_add = c_black
	shader_uniform_hsb_add = c_black
	shader_uniform_rgb_sub = c_black
	shader_uniform_hsb_sub = c_black
	shader_uniform_hsb_mul = c_white
	shader_uniform_mix_color = c_black
	shader_uniform_mix_percent = 0
	
	render_set_uniform_int("uColorsExt", shader_uniform_color_ext)
	render_set_uniform_color("uRGBAdd", shader_uniform_rgb_add, 1)
	render_set_uniform_color("uHSBAdd", shader_uniform_hsb_add, 1)
	render_set_uniform_color("uRGBSub", shader_uniform_rgb_sub, 1)
	render_set_uniform_color("uHSBSub", shader_uniform_hsb_sub, 1)
	render_set_uniform_color("uHSBMul", shader_uniform_hsb_mul, 1)
	render_set_uniform_color("uMixColor", shader_uniform_mix_color, shader_uniform_mix_percent)
	
	render_set_uniform_vec2("uTextureOffset", 0, 0)
	render_set_uniform_int("uMaterialFormat", e_material.FORMAT_NONE)
	
	// Emissive
	shader_uniform_emissive = 0
	render_set_uniform("uEmissive", shader_uniform_emissive)
	
	// Metallic
	shader_uniform_metallic = 0
	render_set_uniform("uMetallic", 0)
	
	// Roughness
	shader_uniform_roughness = 0
	render_set_uniform("uRoughness", shader_uniform_roughness)
	
	// Wind
	shader_uniform_wind = false
	shader_uniform_wind_terrain = false
	render_set_uniform("uWindEnable", shader_uniform_wind)
	render_set_uniform("uWindTerrain", shader_uniform_wind_terrain)
	
	// Fog
	shader_uniform_fog = true
	render_set_uniform_int("uFogShow", shader_uniform_fog)
	
	// SSS
	shader_uniform_sss = 0
	shader_uniform_sss_red = 1
	shader_uniform_sss_green = 1
	shader_uniform_sss_blue = 1
	shader_uniform_sss_color = c_white
	render_set_uniform("uSSS", shader_uniform_sss)
	render_set_uniform_vec3("uSSSRadius", shader_uniform_sss_red,
										  shader_uniform_sss_green,
										  shader_uniform_sss_blue)
	render_set_uniform_color("uSSSColor", shader_uniform_sss_color, 1.0) 
	
	// Wind
	shader_uniform_wind_strength = app.background_wind_strength * app.setting_wind_enable
	
	// Glow
	shader_uniform_glow = false
	shader_uniform_glow_texture = false
	shader_uniform_glow_color = c_white
	
	// Glint
	render_set_uniform_int("uGlintEnabled", 0)
	
	render_blend_prev = null
	render_alpha_prev = null
}
