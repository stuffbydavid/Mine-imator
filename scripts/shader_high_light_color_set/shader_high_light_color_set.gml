/// shader_high_light_color_set()

function shader_high_light_color_set()
{
	// Colors
	render_set_uniform_int("uColorsExt", 0)
	
	render_set_uniform_int("uColoredShadows", app.setting_render_shadows_sun_colored)
}
