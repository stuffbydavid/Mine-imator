/// shader_border_set()

function shader_border_set()
{
	render_set_uniform_vec2("uTexSize", render_width, render_height)
	render_set_uniform_color("uColor", border_mode = e_render_mode.SELECT ? c_white : c_yellow, 1)
}
