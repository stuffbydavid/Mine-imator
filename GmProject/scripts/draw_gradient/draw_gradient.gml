/// draw_gradient(x, y, width, height, color, alphalefttop, alpharighttop, alpharightbottom, alphaleftbottom)
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg color
/// @arg alphalefttop
/// @arg alpharighttop
/// @arg alpharightbottom
/// @arg alphaleftbottom

function draw_gradient(xx, yy, w, h, color, alphalefttop, alpharighttop, alpharightbot, alphaleftbot)
{
	var alpha = draw_get_alpha();
	
	draw_primitive_begin(pr_trianglestrip)
	
	draw_vertex_color(xx, yy, color, alphalefttop * alpha)
	draw_vertex_color(xx + w, yy, color, alpharighttop * alpha)
	draw_vertex_color(xx, yy + h, color, alphaleftbot * alpha)
	draw_vertex_color(xx + w, yy + h, color, alpharightbot * alpha)
	
	draw_primitive_end()
}
