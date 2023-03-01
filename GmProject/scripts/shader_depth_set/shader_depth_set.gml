/// shader_depth_set()

function shader_depth_set()
{
	render_set_uniform("uNear", proj_depth_near)
	render_set_uniform("uFar", proj_depth_far)
}
