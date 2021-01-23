/// sortlist_draw_button(name, x, y, width, height, highlight, icon, isfirst, islast, listmouseon)
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg highlight
/// @arg icon
/// @arg isfirst
/// @arg islast
/// @arg listmouseon

var name, xx, yy, w, h, highlight, icon, isfirst, islast, listmouseon;
var pressed, mouseon, wlimit, text;
name = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4
highlight = argument5
icon = argument6
isfirst = argument7
islast = argument8
listmouseon = argument9
wlimit = w - 16

// Mouse
mouseon = (app_mouse_box(xx, yy, w - 5, h) && content_mouseon && mouse_cursor = cr_default)
pressed = highlight
if (mouseon)
{
	if (mouse_left || mouse_left_released)
		pressed = true
	
	mouse_cursor = cr_handpoint
}

// Separator
if (!isfirst && listmouseon)
	draw_line_ext(xx - 1, yy + 4, xx - 1, yy + h - 4, c_text_tertiary, a_text_tertiary)

draw_set_font(font_emphasis)

// Icon spacing
if (icon != null && mouseon)
	wlimit -= 28

wlimit = max(0, wlimit)
text = string_limit(text_get(name), wlimit)

// Draw icon
if (icon != null && mouseon && wlimit > 28)
	draw_image(spr_icons, icon, xx + 8 + string_width(text) + 4 + 12, yy + h / 2, 1, 1, c_text_secondary, a_text_secondary)

// Draw label
if (!islast || isfirst)
{
	draw_label(text, xx + 8, yy + h / 2, fa_left, fa_middle, c_text_secondary, a_text_secondary)
}
else
{
	var textoff;
	
	if (icon != null && mouseon)
		textoff = 28
	else
		textoff = 0
	
	draw_label(text, xx + (w - 8) - textoff, yy + h / 2, fa_right, fa_middle, c_text_secondary, a_text_secondary)
}

// Check click
if (mouseon && mouse_left_released)
{
	app_mouse_clear()
	return true
}

return false
