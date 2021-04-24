/// shader_high_indirect_depth_normal_set()

function shader_high_indirect_depth_normal_set()
{
	render_set_uniform("uNear", cam_near)
	render_set_uniform("uFar", cam_far)
}
