/// shader_depth_set()

function shader_depth_set()
{
	var camera = render_mode = e_render_mode.DEPTH;
	render_set_uniform_int("uCameraDepth", camera)
	render_set_uniform("uNear", camera ? depth_near : proj_depth_near)
	render_set_uniform("uFar", camera ? depth_far : proj_depth_far)
}
