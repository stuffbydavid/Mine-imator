function shader_color_correction_set()
{
	render_set_uniform(e_uniform.CONTRAST, render_camera_effects[e_value.CAM_FX_CONTRAST] + 1)
	render_set_uniform(e_uniform.BRIGHTNESS, render_camera_effects[e_value.CAM_FX_BRIGHTNESS])
	render_set_uniform(e_uniform.SATURATION, render_camera_effects[e_value.CAM_FX_SATURATION])
	render_set_uniform(e_uniform.VIBRANCE, render_camera_effects[e_value.CAM_FX_VIBRANCE])
	render_set_uniform_color(e_uniform.COLOR_BURN, render_camera_effects[e_value.CAM_FX_COLOR_BURN], 1)
}
