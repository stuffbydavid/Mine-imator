function shader_tonemap_set()
{
	render_set_uniform_int(e_uniform.TONEMAPPER, render_tonemapper)
	render_set_uniform(e_uniform.EXPOSURE, render_exposure)
	render_set_uniform(e_uniform.GAMMA, render_gamma)
}
