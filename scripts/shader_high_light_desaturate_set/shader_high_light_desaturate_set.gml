/// shader_high_light_desaturate_set(shadowsurf, amount)
/// @arg shadowsurf
/// @arg amount

function shader_high_light_desaturate_set(shadowsurf, amount)
{
	amount = 1 - (amount * app.background_night_alpha)
	
	texture_set_stage(sampler_map[?"uShadowBuffer"], surface_get_texture(shadowsurf))
	render_set_uniform("uAmount", amount)
}
