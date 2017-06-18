/// draw_checkbox(name, x, y, checked, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg checked
/// @arg script

var name, xx, yy, checked, script;
var size, caption, w, mouseon, pressed;
name = argument0
xx = argument1
yy = argument2
checked = argument3
script = argument4

size = 16
if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
	return 0

caption = text_get(name)
w = size + string_width(caption) + 10
tip_set(text_get(name + "tip"), xx, yy, w, size)

// Mouse
mouseon = (app_mouse_box(xx, yy, w, size) && content_mouseon)
pressed = false
if (mouseon) 
{
	if (mouse_left || mouse_left_released)
		pressed = true
	mouse_cursor = cr_handpoint
}

// Box
draw_image(spr_checkbox, 0, xx, yy, 1, 1, test(pressed, setting_color_boxes_pressed, setting_color_boxes), 1)

if (checked)
	draw_image(spr_icons, icons.check, xx + ceil(size / 2), yy + ceil(size / 2), 1, 1, setting_color_boxes_text, 1)

// Caption
draw_label(caption, xx + size + 8, yy + size / 2, fa_left, fa_middle)

// Press
if (pressed && mouse_left_released)
	script_execute(script, !checked)
