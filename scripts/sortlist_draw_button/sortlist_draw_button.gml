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

// Tip
tip_set(text_get(name + "tip") + "\n" + text_get("columntip"), xx, yy, w - 5, h)

// Mouse
mouseon = (app_mouse_box(xx, yy, w - 5, h) && content_mouseon && mouse_cursor = cr_default)
pressed = highlight
if (mouseon)
{
	if (mouse_left || mouse_left_released)
		pressed = true
	mouse_cursor = cr_handpoint
}

// Box
draw_box_rounded(xx, yy, w, h, pressed ? setting_color_buttons_pressed : setting_color_buttons, 1, isfirst, islast, false, false)

// Separator
if (!pressed && !isfirst)
{
	render_set_culling(false)
	draw_line_width_color(xx - 2, yy + 6, xx - 2, yy + h-6, 2, setting_color_buttons_pressed, setting_color_buttons_pressed)
	render_set_culling(true)
}

// Icon
if (icon != null)
	draw_image(spr_icons, icon, xx + w - h / 2, yy + h / 2 + pressed, 1, 1, setting_color_buttons_text, 1)
	
// Text
draw_label(string_limit(text_get(name), w - 4 - (icon != null) * 20), xx + floor(w / 2), yy + h / 2 + pressed, fa_center, fa_middle, setting_color_buttons_text, 1)

// Check click
if (mouseon && mouse_left_released)
{
	app_mouse_clear()
	return true
}

return false
