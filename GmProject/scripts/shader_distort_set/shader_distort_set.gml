function shader_distort_set()
{
	render_set_uniform("uDistortAmount", render_camera_effects[e_value.CAM_FX_DISTORT_AMOUNT])
	render_set_uniform_int("uRepeatImage", render_camera_effects[e_value.CAM_FX_DISTORT_REPEAT])
	render_set_uniform("uZoomAmount", render_camera_effects[e_value.CAM_FX_DISTORT_ZOOM_AMOUNT])
}
