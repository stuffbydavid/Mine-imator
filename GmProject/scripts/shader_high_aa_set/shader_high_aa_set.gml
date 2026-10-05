function shader_high_aa_set()
{
	render_set_uniform_vec2(e_uniform.SCREEN_SIZE, render_width, render_height)
	render_set_uniform(e_uniform.POWER, renderer_current = e_renderer.QUICK ? 1 : app.project_render_aa_power)
}
