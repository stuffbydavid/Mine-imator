/// @desc Starts the regular preview shader and lighting.

function render_preview_start()
{
	render_mode = e_render_mode.PREVIEW
	render_material_pass = true
	render_shader_obj = shader_map[?render_mode_shader_map[?render_mode]]
	with (render_shader_obj)
		shader_use()
	
	// Preview uniforms
	render_set_uniform_int(e_uniform.ALPHA_HASH, 0)
	render_set_uniform_color(e_uniform.BLEND_COLOR, shader_blend_color, shader_blend_alpha)
	render_set_uniform_vec2(e_uniform.TEXTURE_OFFSET, 0, 0)
	render_set_material_none()
	
	render_set_uniform(e_uniform.SSS, 0)
	render_set_uniform_vec3(e_uniform.SSS_RADIUS, 1, 1, 1)
	render_set_uniform_color(e_uniform.SSS_COLOR, c_white, 1)
	render_set_uniform_int(e_uniform.GLINT_ENABLED, 0)

	render_set_uniform_vec3(e_uniform.SUN_DIRECTION, 0.408, 0.408, 0.816)
	render_set_uniform_int(e_uniform.LIGHT_AMOUNT, 1)
	render_set_uniform(e_uniform.LIGHT_DATA, [ 0, 0, 0, 0, 1, 1, 1, 0 ])
	render_set_uniform_color(e_uniform.AMBIENT_COLOR, c_ambient, 1)
	render_set_uniform_color(e_uniform.FALLBACK_COLOR, c_white, 1)
				
	render_set_uniform_int(e_uniform.FOG_SHOW, 0)
	render_set_uniform_int(e_uniform.IS_SKY, 0)
	render_set_uniform_int(e_uniform.IS_GROUND, 0)
	render_set_uniform(e_uniform.WIND_ENABLE, 0)
	render_set_uniform(e_uniform.WIND_TERRAIN, 0)

	render_set_uniform_int(e_uniform.TONEMAPPER, 0)
	render_set_uniform(e_uniform.EXPOSURE, 1)
	render_set_uniform(e_uniform.GAMMA, default_gamma)

	render_set_uniform_int(e_uniform.COLORS_EXT, 1)
	render_set_uniform_color(e_uniform.RGB_ADD, tl_value_default(e_value.RGB_ADD), 1)
	render_set_uniform_color(e_uniform.RGB_SUB, tl_value_default(e_value.RGB_SUB), 1)
	render_set_uniform_color(e_uniform.HSB_ADD, tl_value_default(e_value.HSB_ADD), 1)
	render_set_uniform_color(e_uniform.HSB_SUB, tl_value_default(e_value.HSB_SUB), 1)
	render_set_uniform_color(e_uniform.HSB_MUL, tl_value_default(e_value.HSB_MUL), 1)
	render_set_uniform_color(e_uniform.MIX_COLOR, tl_value_default(e_value.MIX_COLOR), tl_value_default(e_value.MIX_PERCENT))
}
