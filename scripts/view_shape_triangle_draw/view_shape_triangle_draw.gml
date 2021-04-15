/// view_shape_triangle_draw(p1, p2, p3)
/// @arg p1
/// @arg p2
/// @arg p3

var p1, p2, p3, color, alpha;
p1 = argument0
p2 = argument1
p3 = argument2

color = draw_get_color()
alpha = draw_get_alpha()

draw_vertex_color(p1[X], p1[Y], color, alpha)
draw_vertex_color(p2[X], p2[Y], color, alpha)
draw_vertex_color(p3[X], p3[Y], color, alpha)
