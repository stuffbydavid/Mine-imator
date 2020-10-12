/// sortlist_draw_button(name, x, y, width, height, highlight, icon, isfirst, islast)
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg highlight
/// @arg icon
/// @arg isfirst
/// @arg islast

var name, xx, yy, w, h, highlight, icon, isfirst, islast;
var pressed, mouseon;
name = argument0
xx = argument1
yy = argument2
w = argument3
h = argument4
highlight = argument5
icon = argument6
isfirst = argument7
islast = argument8

// Mouse
mouseon = (app_mouse_box(xx, yy, w - 5, h) && content_mouseon && mouse_cursor = cr_default)
pressed = highlight
if (mouseon)
{
	if (mouse_left || mouse_left_released)
		pressed = true
	mouse_cursor = cr_handpoint
}

if (pressed)
	draw_box(xx, yy, w, h, false, c_overlay, a_overlay)

// Separator
if (!isfirst)
	draw_line_ext(xx - 1, yy + 8, xx - 1, yy + h - 8, c_border, a_border)

// Icon
if (icon != null)
	draw_image(spr_icons, icon, xx + w - 18, yy + h / 2 + pressed, 1, 1, c_text_secondary, a_text_secondary)

draw_set_font(font_emphasis)

// Text
if (!islast || isfirst)
{
	draw_label(string_limit(text_get(name), w - 16 - (icon != null) * 28), xx + 8, yy + h / 2 + pressed, fa_left, fa_middle, c_text_secondary, a_text_secondary)
}
else
{
	var textlimit, textx;
	
	if (icon = null)
	{
		textlimit = string_limit(text_get(name), w - 16)
		textx = xx + w - 8
	}
	else
	{
		textlimit = string_limit(text_get(name), w - 48)
		textx = xx + w - 32
	}
	
	draw_label(textlimit, textx, yy + h / 2 + pressed, fa_right, fa_middle, c_text_secondary, a_text_secondary)
}

// Check click
if (mouseon && mouse_left_released)
{
	app_mouse_clear()
	return true
}

return false
