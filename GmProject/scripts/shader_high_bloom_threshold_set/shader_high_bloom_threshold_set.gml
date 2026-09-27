/// shader_high_bloom_threshold_set()

function shader_high_bloom_threshold_set()
{
	render_set_uniform("uThreshold", render_camera.value[e_value.CAM_BLOOM_THRESHOLD])
	render_set_uniform("uTransition", render_camera.value[e_value.CAM_BLOOM_TRANSITION])
}
