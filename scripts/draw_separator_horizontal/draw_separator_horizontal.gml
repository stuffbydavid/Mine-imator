/// draw_separator_horizontal(x, y, width)
/// @arg x
/// @arg y
/// @arg width

var xx, yy, wid;
xx = argument0
yy = argument1
wid = argument2

render_set_culling(false)
draw_line_width_color(xx, yy, xx + wid, yy, 2, setting_color_background, setting_color_background)
render_set_culling(true)