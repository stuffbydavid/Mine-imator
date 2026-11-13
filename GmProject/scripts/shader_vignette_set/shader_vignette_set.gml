function shader_vignette_set()
{
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	
	render_set_uniform(e_uniform.RADIUS, render_camera_effects[e_value.CAM_FX_VIGNETTE_RADIUS])
	render_set_uniform(e_uniform.SOFTNESS, render_camera_effects[e_value.CAM_FX_VIGNETTE_SOFTNESS])
	render_set_uniform(e_uniform.STRENGTH, render_camera_effects[e_value.CAM_FX_VIGNETTE_STRENGTH])
	
	render_set_uniform_color(e_uniform.COLOR, render_camera_effects[e_value.CAM_FX_VIGNETTE_COLOR], 1)
}
