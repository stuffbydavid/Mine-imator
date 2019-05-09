/// draw_line_ext(x1, y1, x2, y2, color, alpha)
/// @arg x1
/// @arg y1
/// @arg x2
/// @arg y2
/// @arg color
/// @arg alpha

var x1, y1, x2, y2, color, alpha;
x1 = argument0
y1 = argument1
x2 = argument2
y2 = argument3

color = argument4
alpha = argument5 * draw_get_alpha()

draw_primitive_begin(pr_linelist)

draw_vertex_color(x1, y1, color, alpha)
draw_vertex_color(x2, y2, color, alpha)

draw_primitive_end()

