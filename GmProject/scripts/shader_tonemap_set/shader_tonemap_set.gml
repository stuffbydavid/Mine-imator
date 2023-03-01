/// shader_tonemap_set(mask)
/// @arg mask

function shader_tonemap_set(mask)
{
	render_set_uniform_int("uTonemapper", render_tonemapper)
	render_set_uniform("uExposure", render_exposure)
	render_set_uniform("uGamma", render_gamma)
	texture_set_stage(sampler_map[?"uMask"], surface_get_texture(mask))
}
