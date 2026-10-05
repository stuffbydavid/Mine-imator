function shader_distort_set()
{
	render_set_uniform(e_uniform.DISTORT_AMOUNT, render_camera_effects[e_value.CAM_FX_DISTORT_AMOUNT])
	render_set_uniform_int(e_uniform.REPEAT_IMAGE, render_camera_effects[e_value.CAM_FX_DISTORT_REPEAT])
	render_set_uniform(e_uniform.ZOOM_AMOUNT, render_camera_effects[e_value.CAM_FX_DISTORT_ZOOM_AMOUNT])
}
