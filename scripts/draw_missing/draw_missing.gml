/// draw_missing(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var xx, yy, w, h;
xx = argument0
yy = argument1
w = argument2
h = argument3

draw_box(xx, yy, w, h, false, c_fuchsia, 1)
draw_box(xx + w / 2, yy, w / 2, h / 2, false, c_black, 1)
draw_box(xx, yy + h / 2, w / 2, h / 2, false, c_black, 1)