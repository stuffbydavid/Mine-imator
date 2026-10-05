function shader_depth_point_set()
{
	render_set_uniform_vec3(e_uniform.EYE, render_proj_from[X], render_proj_from[Y], render_proj_from[Z])
	render_set_uniform(e_uniform.NEAR, proj_depth_near)
	render_set_uniform(e_uniform.FAR, proj_depth_far)
}
