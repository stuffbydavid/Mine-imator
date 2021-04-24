/// draw_circle_ext(x, y, radius, outline, detail, color, alpha)
/// @arg x
/// @arg y
/// @arg radius
/// @arg outline
/// @arg detail
/// @arg color
/// @arg alpha

function draw_circle_ext(xx, yy, rad, outline, detail, color, alpha)
{
	var oldcolor, oldalpha;
	oldcolor = draw_get_color()
	oldalpha = draw_get_alpha()
	draw_set_color(color)
	draw_set_alpha(oldalpha * alpha)
	
	if (outline)
		draw_primitive_begin(pr_linestrip)
	else
	{
		draw_primitive_begin(pr_trianglefan)
		draw_vertex(xx, yy)
	}
	
	for (var s = 0; s <= pi * 2; s += (pi * 2) / detail)
		draw_vertex(xx + cos(s) * rad, yy + sin(s) * rad)
	
	draw_primitive_end()
	
	draw_set_color(oldcolor)
	draw_set_alpha(oldalpha)
}
