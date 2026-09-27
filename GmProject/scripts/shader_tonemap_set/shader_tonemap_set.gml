/// shader_tonemap_set()

function shader_tonemap_set()
{
	render_set_uniform_int("uTonemapper", render_tonemapper)
	render_set_uniform("uExposure", render_exposure)
	render_set_uniform("uGamma", render_gamma)
}
