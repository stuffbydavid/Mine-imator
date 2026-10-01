function shader_ca_set()
{
	render_set_uniform("uBlurAmount", render_camera_effects[e_value.CAM_FX_CA_BLUR_AMOUNT])
	render_set_uniform_vec3("uColorOffset", render_camera_effects[e_value.CAM_FX_CA_RED_OFFSET], render_camera_effects[e_value.CAM_FX_CA_GREEN_OFFSET], render_camera_effects[e_value.CAM_FX_CA_BLUE_OFFSET])
	render_set_uniform_int("uDistortChannels", render_camera_effects[e_value.CAM_FX_CA_DISTORT_CHANNELS])
}
