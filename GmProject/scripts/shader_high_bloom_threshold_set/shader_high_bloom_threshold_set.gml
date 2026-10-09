function shader_high_bloom_threshold_set()
{
	render_set_uniform(e_uniform.THRESHOLD, render_camera_effects[e_value.CAM_FX_BLOOM_THRESHOLD])
	render_set_uniform(e_uniform.TRANSITION, render_camera_effects[e_value.CAM_FX_BLOOM_TRANSITION])
}
