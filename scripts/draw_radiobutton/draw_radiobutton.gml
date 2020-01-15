/// draw_radiobutton(name, x, y, value, checked, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg checked
/// @arg script

var name, xx, yy, value, checked, script;
var size, rad, caption, wid, mouseon, pressed;
name = argument0
xx = argument1
yy = argument2
value = argument3
checked = argument4
script = argument5

size = 16
if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
	return 0
	
rad = size / 2
caption = text_get(name)
wid = size + string_width(caption) + 10
tip_set(text_get(name + "tip"), xx, yy, wid, size)

// Mouse
mouseon = (app_mouse_box(xx, yy, wid, size) && content_mouseon)
pressed = false
if (mouseon)
{
	if (mouse_left || mouse_left_released)
		pressed = true
	mouse_cursor = cr_handpoint
}

// Circle
draw_image(spr_circle_16, 0, xx + rad, yy + rad, 1, 1, pressed ? setting_color_boxes_pressed : setting_color_boxes, 1)

if (checked)
	draw_image(spr_circle_8, 0, xx + rad, yy + rad, 1, 1, setting_color_buttons, 1)

// Caption
draw_label(caption, xx + size + 8, yy + size / 2, fa_left, fa_middle)

// Press
if (pressed && mouse_left_released)
	script_execute(script, value)
