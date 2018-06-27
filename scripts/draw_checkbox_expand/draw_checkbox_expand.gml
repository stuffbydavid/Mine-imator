/// draw_checkbox_expand(name, x, y, checked, script, expanded, expandscript)
/// @arg name
/// @arg x
/// @arg y
/// @arg checked
/// @arg script
/// @arg expanded
/// @arg expandscript

var name, xx, yy, checked, script, expanded, expandscript;
var size, expandwidth, caption, w, checkboxmouseon, checkboxpressed, expandmouseon, expandpressed;
name = argument0
xx = argument1
yy = argument2
checked = argument3
script = argument4
expanded = argument5
expandscript = argument6

size = 16
expandwidth = 32
if (xx + size < content_x || xx > content_x + content_width || yy + size < content_y || yy > content_y + content_height)
	return 0

caption = text_get(name)
w = size + string_width(caption) + 10
tip_set(text_get(name + "tip"), xx + (expandwidth + 4), yy, w, size)

if (checked)
	tip_set(text_get("expandcollapsetip"), xx, yy, expandwidth, size)

// Expand mouse
expandmouseon = (app_mouse_box(xx, yy, expandwidth, size) && content_mouseon)
expandpressed = false
if (expandmouseon && checked) 
{
	if (mouse_left || mouse_left_released)
		expandpressed = true
	mouse_cursor = cr_handpoint
}

// Checkbox mouse
checkboxmouseon = (app_mouse_box(xx + (expandwidth + 4), yy, w, size) && content_mouseon)
checkboxpressed = false
if (checkboxmouseon) 
{
	if (mouse_left || mouse_left_released)
		checkboxpressed = true
	mouse_cursor = cr_handpoint
}

// Expand box
if ((expandmouseon || expanded) && checked)
	draw_box_rounded(xx, yy, expandwidth, 16, test(expandpressed || expanded, setting_color_buttons_pressed, setting_color_buttons), 1)

draw_image(spr_icons, icons.EXPAND, xx + round(expandwidth/2), (yy + 8) + ((expandpressed || expanded) && checked), 1, 1, test((expandmouseon || expanded) && checked, setting_color_buttons_text, setting_color_boxes_text), test(checked, 1, 0.5))

xx += (expandwidth + 4)

// Checkbox
draw_image(spr_checkbox, 0, xx, yy, 1, 1, test(checkboxpressed, setting_color_boxes_pressed, setting_color_boxes), 1)

if (checked)
	draw_image(spr_icons, icons.CHECK, xx + ceil(size / 2), yy + ceil(size / 2), 1, 1, setting_color_boxes_text, 1)

// Caption
draw_label(caption, xx + size + 8, yy + size / 2, fa_left, fa_middle)

// Expand press
if (expandpressed && mouse_left_released && checked)
	script_execute(expandscript, !expanded)

// Checkbox press
if (checkboxpressed && mouse_left_released)
	script_execute(script, !checked)
