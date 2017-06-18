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

var xx, yy, w, h, color, alphalefttop, alpharighttop, alpharightbot, alphaleftbot;
var alpha;
xx = argument0
yy = argument1
w = argument2
h = argument3
color = argument4
alphalefttop = argument5
alpharighttop = argument6
alpharightbot = argument7
alphaleftbot = argument8
alpha = draw_get_alpha()

draw_primitive_begin(pr_trianglestrip)

draw_vertex_color(xx, yy, color, alphalefttop * alpha)
draw_vertex_color(xx + w, yy, color, alpharighttop * alpha)
draw_vertex_color(xx, yy + h, color, alphaleftbot * alpha)
draw_vertex_color(xx + w, yy + h, color, alpharightbot * alpha)

draw_primitive_end()
