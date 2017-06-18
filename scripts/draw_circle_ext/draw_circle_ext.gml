/// draw_circle_ext(x, y, radius, outline, detail, color, alpha)
/// @arg x
/// @arg y
/// @arg radius
/// @arg outline
/// @arg detail
/// @arg color
/// @arg alpha

var xx, yy, rad, outline, detail, color, alpha;
xx = argument0
yy = argument1
rad = argument2
outline = argument3
detail = argument4

color = draw_get_color()
alpha = draw_get_alpha()
draw_set_color(argument5)
draw_set_alpha(alpha * argument6)

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

draw_set_color(color)
draw_set_alpha(alpha)
