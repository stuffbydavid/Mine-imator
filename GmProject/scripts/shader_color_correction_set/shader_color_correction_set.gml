function shader_color_correction_set()
{
	render_set_uniform("uContrast", render_camera_effects[e_value.CAM_FX_CONTRAST] + 1)
	render_set_uniform("uBrightness", render_camera_effects[e_value.CAM_FX_BRIGHTNESS])
	render_set_uniform("uSaturation", render_camera_effects[e_value.CAM_FX_SATURATION])
	render_set_uniform("uVibrance", render_camera_effects[e_value.CAM_FX_VIBRANCE])
	render_set_uniform_color("uColorBurn", render_camera_effects[e_value.CAM_FX_COLOR_BURN], 1)
}
