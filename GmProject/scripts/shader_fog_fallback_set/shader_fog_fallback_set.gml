/// shader_fog_fallback_set()

function shader_fog_fallback_set()
{
	render_set_uniform("uViewMatrixInv", matrix_inverse_ext(view_matrix))

	var fogheight = (app.background_fog_height / 1000) * (1 + max(app.background_sunrise_alpha, app.background_sunset_alpha))
	render_set_uniform_vec2("uFog", app.project_render_distance * 0.75, fogheight)
	render_set_uniform_int("uFogEnabled", render_background && app.background_fog_show && app.background_fog_sky)
}
