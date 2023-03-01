/// draw_line_ext(x1, y1, x2, y2, color, alpha)
/// @arg x1
/// @arg y1
/// @arg x2
/// @arg y2
/// @arg color
/// @arg alpha

function draw_line_ext(x1, y1, x2, y2, color, alpha)
{
	alpha = alpha * draw_get_alpha()
	
	draw_primitive_begin(pr_linelist)
	
	draw_vertex_color(x1, y1, color, alpha)
	draw_vertex_color(x2, y2, color, alpha)
	
	draw_primitive_end()
}
