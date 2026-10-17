function shader_depth_set()
{
	var camera = render_mode = e_render_mode.DEPTH;
	render_set_uniform_int(e_uniform.CAMERA_DEPTH, camera)
	render_set_uniform(e_uniform.NEAR, camera ? depth_near : proj_depth_near)
	render_set_uniform(e_uniform.FAR, camera ? depth_far : proj_depth_far)
}
