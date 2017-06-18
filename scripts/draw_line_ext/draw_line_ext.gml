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

color = draw_get_color()
alpha = draw_get_alpha()

draw_set_color(argument4)
draw_set_alpha(alpha * argument5)

draw_line(x1, y1, x2, y2)

draw_set_color(color)
draw_set_alpha(alpha)
