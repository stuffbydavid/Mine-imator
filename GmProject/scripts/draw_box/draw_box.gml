/// draw_box(x, y, width, height, outline, [color, alpha])
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg outline
/// @arg [color
/// @arg alpha]

function draw_box(xx, yy, width, height, outline, incolor, inalpha)
{
	var color, alpha;
	
	color = draw_get_color()
	alpha = draw_get_alpha()
	
	if (!is_undefined(incolor))
	{
		color = incolor
		alpha *= inalpha
	}
	
	if (alpha = 0 || width <= 0 || height <= 0)
		return 0
	
	draw_primitive_begin(outline ? pr_linestrip : pr_trianglefan)
	
	draw_vertex_color(xx, yy, color, alpha)
	draw_vertex_color(xx + width, yy, color, alpha)
	draw_vertex_color(xx + width, yy + height, color, alpha)
	draw_vertex_color(xx, yy + height, color, alpha)
	draw_vertex_color(xx, yy, color, alpha)
	
	draw_primitive_end()
}
