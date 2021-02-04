/// colorpicker_draw()

var bx, by, bw, bh;
bx = dx - 12
by = dy - 12
bw = 192
bh = 192

// Saturation/brightness picker
if (app_mouse_box(bx, by, bw, bh))
{
	mouse_cursor = cr_handpoint
	if (mouse_left)
		window_busy = "colorpickersatbripick"
}

if (window_busy = "colorpickersatbripick")
{
	if (!mouse_left)
	{
		window_busy = ""
		window_focus = ""
		app_mouse_clear()
	}
	
	mouse_cursor = cr_handpoint
	colorpicker.saturation = floor((clamp((mouse_x - bx) / bw, 0, 1)) * 255)
	colorpicker.brightness = floor((clamp(1 - (mouse_y - by) / bh, 0, 1)) * 255)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}

draw_sprite_general(spr_colorpicker, 0, 0, 0, 228, 228, bx, by, 1, 1, 0, c_white, make_color_hsv(colorpicker.hue, 255, 255), make_color_hsv(colorpicker.hue, 255, 255), c_white, draw_get_alpha())
draw_image(spr_colorpicker_cursor, 0, bx + (bw * (colorpicker.saturation/255)), by + (bh * (1 - (colorpicker.brightness/255))), 1, 1, c_white, 1)
dy = by + 192 + 8
dx -= 4
dw = 176

bx = dx + 8
by = dy
bw = 176 - 16
bh = 16

// Hue picker
if (app_mouse_box(bx - 8, by, bw + 16, bh))
{
	mouse_cursor = cr_handpoint
	if (mouse_left)
		window_busy = "colorpickerhuepick"
}

if (window_busy = "colorpickerhuepick")
{
	if (!mouse_left)
	{
		window_busy = ""
		app_mouse_clear()
	}
	
	mouse_cursor = cr_handpoint
	colorpicker.hue = floor(clamp((mouse_x - bx) / bw, 0, 1) * 255)
	colorpicker_update(null, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
}

draw_image(spr_colorpicker_hue, 0, dx, by, 1, 1, c_white, 1)
draw_outline(dx, by, 176, 16, 1, c_border, a_border, true)
draw_image(spr_colorpicker_cursor, 1, bx + ((colorpicker.hue/255) * bw), by + 8, 1, 1)
dy += 16 + 8

tab_control_button_label()
togglebutton_add("colorpickerrgb", null, "rgb", colorpicker.mode = "rgb", colorpicker_set_mode)
togglebutton_add("colorpickerhsl", null, "hsl", colorpicker.mode = "hsl", colorpicker_set_mode)
togglebutton_add("colorpickerhex", null, "hex", colorpicker.mode = "hex", colorpicker_set_mode)
draw_togglebutton("colorpickermode", dx, dy, true, false)
tab_next()

if (colorpicker.mode = "rgb")
{
	// RGB
	textfield_group_add("colorpickerr", color_get_red(colorpicker.color), color_get_red(colorpicker.def), colorpicker_reset_red, X, colorpicker.tbx_red)
	textfield_group_add("colorpickerg", color_get_green(colorpicker.color), color_get_green(colorpicker.def), colorpicker_reset_green, X, colorpicker.tbx_green)
	textfield_group_add("colorpickerb", color_get_blue(colorpicker.color), color_get_blue(colorpicker.def), colorpicker_reset_blue, X, colorpicker.tbx_blue)
	if (draw_textfield_group("colorpickerrgb", dx, dy, 176, 1, 0, 255, 1, false, false, 1, true, false))
	{
		colorpicker.red = min(255, string_get_real(colorpicker.tbx_red.text, 0))
		colorpicker.green = min(255, string_get_real(colorpicker.tbx_green.text, 0))
		colorpicker.blue = min(255, string_get_real(colorpicker.tbx_blue.text, 0))
		colorpicker_update(null, make_color_rgb(colorpicker.red, colorpicker.green, colorpicker.blue), true)
	}
}
else if (colorpicker.mode = "hsl")
{
	// HSL
	textfield_group_add("colorpickerh", floor(color_get_hue(colorpicker.color)), floor(color_get_hue(colorpicker.def)), colorpicker_reset_hue, X, colorpicker.tbx_hue)
	textfield_group_add("colorpickers", floor(color_get_saturation(colorpicker.color)), floor(color_get_saturation(colorpicker.def)), colorpicker_reset_saturation, X, colorpicker.tbx_saturation)
	textfield_group_add("colorpickerl", floor(color_get_value(colorpicker.color)), floor(color_get_value(colorpicker.def)), colorpicker_reset_brightness, X, colorpicker.tbx_brightness)
	var update = draw_textfield_group("colorpickerhsl", dx, dy, 176, 1, 0, 255, 1, false, false, 1, true, false);
	if (update = colorpicker.tbx_hue)
	{
		colorpicker.hue = min(255, string_get_real(colorpicker.tbx_hue.text, 0))
		colorpicker_update(colorpicker.tbx_hue, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
	}
	if (update = colorpicker.tbx_saturation)
	{
		colorpicker.saturation = min(255, string_get_real(colorpicker.tbx_saturation.text, 0))
		colorpicker_update(colorpicker.tbx_saturation, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
	}
	if (update = colorpicker.tbx_brightness)
	{
		colorpicker.brightness = min(255, string_get_real(colorpicker.tbx_brightness.text, 0))
		colorpicker_update(colorpicker.tbx_brightness, make_color_hsv(colorpicker.hue, colorpicker.saturation, colorpicker.brightness), false)
	}
}
else if (colorpicker.mode = "hex")
{
	if (draw_inputbox("colorpickerhex", dx, dy, 176, 24, "000000", colorpicker.tbx_hexadecimal, null))
		colorpicker_update(colorpicker.tbx_hexadecimal, hex_to_color(colorpicker.tbx_hexadecimal.text), false)
	
	if (colorpicker.tbx_hexadecimal.text = "" && window_focus = "")
		colorpicker.tbx_hexadecimal.text = "000000"
}

dy += 24 + 8

settings_menu_w = 192
