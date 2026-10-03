function shader_high_bloom_threshold_set()
{
	render_set_uniform("uThreshold", render_camera_effects[e_value.CAM_FX_BLOOM_THRESHOLD])
	render_set_uniform("uTransition", render_camera_effects[e_value.CAM_FX_BLOOM_TRANSITION])
}
