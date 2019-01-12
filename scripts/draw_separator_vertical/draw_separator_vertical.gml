/// draw_separator_vertical(x, y, height)
/// @arg x
/// @arg y
/// @arg height

var xx, yy, hei;
xx = argument0
yy = argument1
hei = argument2

render_set_culling(false)
draw_line_width_color(xx, yy, xx, yy + hei, 2, setting_color_background, setting_color_background)
render_set_culling(true)