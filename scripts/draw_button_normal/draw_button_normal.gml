/// draw_button_normal(name, x, y, width, height, [type, pressed, frame, enabled, [ icon, [ iconblend, [tip]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [type
/// @arg pressed
/// @arg frame
/// @arg enabled
/// @arg [icon
/// @arg [iconblend
/// @arg [tip]]]]
/// @desc Draws a button with the given properties.

var name, xx, yy, wid, hei, type, pressed, frame, enabled, icon, iconblend, tip;
var text, mouseon, alpha;

name = argument[0]
xx = argument[1]
yy = argument[2]
wid = argument[3]
hei = argument[4]

if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	return 0

type = e_button.TEXT
pressed = false
frame = true
enabled = true
if (argument_count > 5)
{
	type = argument[5]
	pressed = argument[6]
	frame = argument[7]
	enabled = argument[8]
}

icon = null
if (argument_count > 9)
	icon = argument[9]

iconblend = c_white
if (argument_count > 10)
	iconblend = argument[10]

tip = ""
if (argument_count > 11)
	tip = argument[11]
else if (text_exists(name + "tip"))
	tip = text_get(name + "tip")

if (pressed)
	frame = true

// Get text
if (type = e_button.NO_TEXT)
	text = ""
else
	text = text_get(name)
	
if (wid < 0)
	wid = string_width(text) + 20

if (type = e_button.CAPTION)
{
	mouseon = app_mouse_box(xx, yy, wid + 5 + string_width(text), hei)
	tip_set(tip, xx, yy, wid + 5 + string_width(text), hei)
}
else
{
	mouseon = app_mouse_box(xx, yy, wid, hei)
	tip_set(tip, xx, yy, wid, hei)
}

if (!content_mouseon || !enabled)
	mouseon = false

if (mouseon)
{
	if (mouse_left || mouse_left_released)
		pressed = true
	frame = true
	mouse_cursor = cr_handpoint
}

alpha = draw_get_alpha()
if (!enabled)
	draw_set_alpha(alpha * 0.25)

// Button
if (frame && icon < icons.rendersmall)
	draw_box_rounded(xx, yy, wid, hei, test(pressed, setting_color_buttons_pressed, setting_color_buttons), 1)

// Icon
if (icon != null)
{
	var iconx, icony;
	iconx = xx + floor(wid / 2)
	icony = yy + hei / 2 + pressed
	if (type = e_button.TEXT)
		iconx -= string_width(text) / 2
		
	if (icon = icons.color)
	{
		draw_image(spr_icons, icon, iconx, icony, 1, 1, iconblend, 1)
		draw_image(spr_icons, icons.colorframe, iconx, icony, 1, 1, c_black, 0.5)
	}
	else if (icon >= icons.rendersmall)
		draw_image(spr_icons_render, icon - icons.rendersmall, iconx, icony, 1, 1, c_white, 1 - 0.75 * !view_render)
	else if (icon >= icons.upgradesmall)
		draw_image(spr_icons_big, icon - icons.websitesmall, iconx, icony, 1, 1, c_yellow, 1)
	else if (icon >= icons.websitesmall)
		draw_image(spr_icons_big, icon - icons.websitesmall, iconx, icony, 1, 1, test(frame, setting_color_buttons_text, setting_color_text), 1)
	else
		draw_image(spr_icons, icon, iconx, icony, 1, 1, test(frame, setting_color_buttons_text, setting_color_text), 1)
}

// Text
if (text != "")
{
	var textx, texty;
	if (type = e_button.CAPTION)
	{
		textx = xx + wid + 5
		texty = yy + hei / 2 - 1
		draw_label(text, textx, texty, fa_left, fa_middle)
	}
	else
	{
		textx = xx + floor(wid / 2)
		texty = yy + hei / 2 + pressed
		if (icon != null)
			textx += 14
		draw_label(text, textx, texty, fa_center, fa_middle, setting_color_buttons_text, 1)
	}
}

if (!enabled)
	draw_set_alpha(alpha)

// Check click
if (mouseon && mouse_left_released)
{
	app_mouse_clear()
	return true
}

return false
