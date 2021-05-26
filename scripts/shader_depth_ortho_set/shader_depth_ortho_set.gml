/// shader_depth_ortho_set()

function shader_depth_ortho_set()
{
	render_set_uniform_int("uColoredShadows", app.project_render_shadows_sun_colored)
}
