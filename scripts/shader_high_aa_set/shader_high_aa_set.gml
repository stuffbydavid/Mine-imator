/// shader_high_aa_set()

function shader_high_aa_set()
{
	render_set_uniform_vec2("uScreenSize", render_width, render_height)
	render_set_uniform("uPower", app.setting_render_aa_power)
}
