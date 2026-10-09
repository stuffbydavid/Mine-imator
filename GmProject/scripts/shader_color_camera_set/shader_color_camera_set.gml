function shader_color_camera_set()
{
	// Color
	render_set_uniform(e_uniform.EMISSIVE, render_camera_effects[e_value.EMISSIVE])
	render_set_uniform_color(e_uniform.BLEND_COLOR, render_camera_effects[e_value.RGB_MUL], render_camera_effects[e_value.ALPHA])
	render_set_uniform_color(e_uniform.RGB_ADD, render_camera_effects[e_value.RGB_ADD], 1)
	render_set_uniform_color(e_uniform.RGB_SUB, render_camera_effects[e_value.RGB_SUB], 1)
	render_set_uniform_color(e_uniform.HSB_ADD, render_camera_effects[e_value.HSB_ADD], 1)
	render_set_uniform_color(e_uniform.HSB_SUB, render_camera_effects[e_value.HSB_SUB], 1)
	render_set_uniform_color(e_uniform.HSB_MUL, render_camera_effects[e_value.HSB_MUL], 1)
	render_set_uniform_color(e_uniform.MIX_COLOR, render_camera_effects[e_value.MIX_COLOR], render_camera_effects[e_value.MIX_PERCENT])
}
