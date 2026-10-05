function shader_border_set()
{
	render_set_uniform_vec2(e_uniform.TEX_SIZE, render_width, render_height)
	
	var col = c_white;
	if (render_mode = e_render_mode.PLACE_SELECT)
		col = c_yellow
	else if (render_mode = e_render_mode.PLACE_PARENT)
		col = make_color_rgb(176, 164, 255)
	
	render_set_uniform_color(e_uniform.COLOR, col, 1)
}
