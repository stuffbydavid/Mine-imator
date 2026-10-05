function shader_fog_fallback_set()
{
	render_set_uniform(e_uniform.VIEW_MATRIX_INV, matrix_inverse_ext(view_matrix))

	var fogheight = (app.env_fog_height / 1000) * (1 + max(app.env_sunrise_alpha, app.env_sunset_alpha));
	render_set_uniform_vec2(e_uniform.FOG, app.project_render_distance * 0.75, fogheight)
	render_set_uniform_int(e_uniform.FOG_ENABLED, render_background && app.env_fog_show && app.env_fog_sky)
}
