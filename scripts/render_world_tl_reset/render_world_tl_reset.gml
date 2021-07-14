/// render_world_tl_reset()
/// @desc Resets render values after finishing rendering timelines

function render_world_tl_reset()
{
	matrix_world_reset()
	render_set_culling(true)
	shader_texture_filter_linear = false
	shader_texture_filter_mipmap = false
	
	render_set_uniform("uBrightness", 0)
	render_set_uniform("uMetallic", 0)
	render_set_uniform("uRoughness", 1)
	
	render_set_uniform_int("uColorsExt", 0)
	render_set_uniform("uWindEnable", 0)
	render_set_uniform("uWindTerrain", 1)
	render_set_uniform_int("uFogShow", (render_fog && app.background_fog_show))
	render_set_uniform_int("uSSAOEnable", 1)
	
	render_set_uniform("uSSS", 0)
	render_set_uniform_vec3("uSSSRadius", 0, 0, 0)
	render_set_uniform_color("uSSSColor", c_black, 1)
	
	render_texture_prev = null
	render_blend_prev = null
	render_alpha_prev = null
}
