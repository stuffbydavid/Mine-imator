/// draw_separator_vertical(x, y, height)
/// @arg x
/// @arg y
/// @arg height

function draw_separator_vertical(xx, yy, hei)
{
	var alpha = draw_get_alpha();
	
	draw_set_alpha(alpha * a_border)
	
	render_set_culling(false)
	draw_line_width_color(xx, yy, xx, yy + hei, 1, c_border, c_border)
	render_set_culling(true)
	
	draw_set_alpha(alpha)
}
