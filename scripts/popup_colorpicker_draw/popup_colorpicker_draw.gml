/// popup_colorpicker_draw()

dy += 8

// Caption
draw_label(text_get(popup.value_name), dx + 16, dy + 14, fa_left, fa_middle, c_accent, 1, font_heading)

// Close
if (draw_button_icon("colorpickerclose", dx + dw - 12 - 28, dy, 28, 28, false, icons.CLOSE, null, false))
	popup_close()

dy += 28 + 8

// Saturation / Brightness picker
draw_sprite_general(spr_colorpicker, 0, 0, 0, 228, 228, dx, dy, 1, 1, 0, c_white, make_color_hsv(popup.hue, 255, 255), make_color_hsv(popup.hue, 255, 255), c_white, draw_get_alpha())
draw_circle_ext(dx + ((popup.saturation / 255) * 228) - 1, dy + ((1 - popup.brightness / 255) * 228) - 1, 7, false, 10, popup.color, 1)
draw_image(spr_colorpicker_cursor, 0, dx + (popup.saturation / 255) * 228, dy + (1 - popup.brightness / 255) * 228)
if (app_mouse_box(dx, dy, 228, 228))
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
		app_mouse_clear()
	}
	mouse_cursor = cr_handpoint
	popup.saturation = floor((clamp((mouse_x - dx) / 228, 0, 1)) * 255)
	popup.brightness = floor((clamp(1 - (mouse_y - dy) / 228, 0, 1)) * 255)
	popup_colorpicker_update(null, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
dy += 228 + 12

// Hue picker
draw_image(spr_colorpicker_hue, 0, dx + 16, dy)
draw_box(dx + floor((popup.hue / 255) * 196) + 10, dy + 4, 12, 12, false, make_color_hsv(popup.hue, 255, 255), 1)
draw_image(spr_colorpicker_cursor, 1, dx + floor((popup.hue / 255) * 196) + 16, dy + 10)

if (app_mouse_box(dx + 16, dy, 196, 20))
{
	mouse_cursor = cr_handpoint
	window_focus = "colorpickerhuepick"
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
	popup.hue = floor(clamp((mouse_x - (dx + 16)) / 196, 0, 1) * 255)
	popup_colorpicker_update(null, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
dy += 20 + 12

// RGB
textfield_group_add("colorpickerr", color_get_red(popup.color), color_get_red(popup.def), null, X, popup.tbx_red)
textfield_group_add("colorpickerg", color_get_green(popup.color), color_get_green(popup.def), null, X, popup.tbx_green)
textfield_group_add("colorpickerb", color_get_blue(popup.color), color_get_blue(popup.def), null, X, popup.tbx_blue)
if (draw_textfield_group("colorpickerrgb", dx + 16, dy, 196, 1, 0, 255, 1))
{
	popup.red = min(255, string_get_real(popup.tbx_red.text, 0))
	popup.green = min(255, string_get_real(popup.tbx_green.text, 0))
	popup.blue = min(255, string_get_real(popup.tbx_blue.text, 0))
	popup_colorpicker_update(null, make_color_rgb(popup.red, popup.green, popup.blue), true)
}
dy += 28 + 12

// HSL
textfield_group_add("colorpickerh", floor(color_get_hue(popup.color)), floor(color_get_hue(popup.def)), null, X, popup.tbx_hue)
textfield_group_add("colorpickers", floor(color_get_saturation(popup.color)), floor(color_get_saturation(popup.def)), null, X, popup.tbx_saturation)
textfield_group_add("colorpickerv", floor(color_get_value(popup.color)), floor(color_get_value(popup.def)), null, X, popup.tbx_brightness)
var update = draw_textfield_group("colorpickerhsv", dx + 16, dy, 196, 1, 0, 255, 1);
if (update = popup.tbx_hue)
{
	popup.hue = min(255, string_get_real(popup.tbx_hue.text, 0))
	popup_colorpicker_update(popup.tbx_hue, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
if (update = popup.tbx_saturation)
{
	popup.saturation = min(255, string_get_real(popup.tbx_saturation.text, 0))
	popup_colorpicker_update(popup.tbx_saturation, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
if (update = popup.tbx_brightness)
{
	popup.brightness = min(255, string_get_real(popup.tbx_brightness.text, 0))
	popup_colorpicker_update(popup.tbx_brightness, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
dy += 28 + 12

// Hex
if (draw_textfield("colorpickerhex", dx + 16, dy, 196, 28, popup.tbx_hexadecimal, null, "", "left"))
	popup_colorpicker_update(popup.tbx_hexadecimal, hex_to_color(popup.tbx_hexadecimal.text), true)
