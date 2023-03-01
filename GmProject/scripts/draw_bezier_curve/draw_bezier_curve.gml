/// draw_bezier_curve(p1, p2, p3, p4, w, color, alpha)
/// @arg p1
/// @arg p2
/// @arg p3
/// @arg p4
/// @arg w
/// @arg color
/// @arg alpha

function draw_bezier_curve(p1, p2, p3, p4, w, color, alpha)
{
	var prevcolor, prevalpha, p, prevp;
	prevcolor = draw_get_color()
	prevalpha = draw_get_alpha()
	
	draw_set_color(color)
	draw_set_alpha(alpha)
	
	p = [0, 0]
	
	for (var i = 0; i < 64; i++)
	{
		prevp = p
		p = bezier_curve_cubic(p1, p2, p3, p4, i / 64)
		
		if (i = 0)
			continue
		
		draw_image(spr_handle, 0, prevp[X], prevp[Y], .75, point_distance(prevp[X], prevp[Y], p[X], p[Y]), color, alpha, point_direction(prevp[X], prevp[Y], p[X], p[Y]) - 90)
	}
	
	draw_set_color(prevcolor)
	draw_set_alpha(prevalpha)
}