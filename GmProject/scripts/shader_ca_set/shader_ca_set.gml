function shader_ca_set()
{
	render_set_uniform(e_uniform.BLUR_AMOUNT, render_camera_effects[e_value.CAM_FX_CA_BLUR_AMOUNT])
	render_set_uniform_vec3(e_uniform.COLOR_OFFSET, render_camera_effects[e_value.CAM_FX_CA_RED_OFFSET], render_camera_effects[e_value.CAM_FX_CA_GREEN_OFFSET], render_camera_effects[e_value.CAM_FX_CA_BLUE_OFFSET])
	render_set_uniform_int(e_uniform.DISTORT_CHANNELS, render_camera_effects[e_value.CAM_FX_CA_DISTORT_CHANNELS])
}
