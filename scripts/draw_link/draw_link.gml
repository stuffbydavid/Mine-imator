/// draw_link(name, string, x, y)
/// @arg name
/// @arg string
/// @arg x
/// @arg y

var name, str, xx, yy;
var wid, hei;
name = argument0
str = argument1
xx = argument2
yy = argument3

wid = string_width(str)
hei = string_height(str)

draw_line_ext(xx - 1, yy + hei - 1, xx + wid, yy + hei - 1, setting_color_buttons, 1)
draw_label(str, xx, yy, fa_left, fa_top, setting_color_buttons, 1)

tip_set(text_get(name + "tip"), xx, yy, wid, hei)
if (app_mouse_box(xx, yy, wid, hei))
{
    mouse_cursor = cr_handpoint
    if (mouse_left_pressed)
        return true
}

return false
