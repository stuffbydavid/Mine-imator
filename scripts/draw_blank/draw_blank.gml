/// draw_blank(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_blank(xx, yy, w, h)
{
	draw_primitive_begin(pr_trianglestrip)
	
	draw_vertex_texture(xx, yy, 0, 0)
	draw_vertex_texture(xx + w, yy, 1, 0)
	draw_vertex_texture(xx, yy + h, 0, 1)
	draw_vertex_texture(xx + w, yy + h, 1, 1)
	
	draw_primitive_end()
}
