/// shader_high_gbuffers_set()

function shader_high_gbuffers_set()
{
	render_set_uniform("uNear", depth_near)
	render_set_uniform("uFar", depth_far)
}
