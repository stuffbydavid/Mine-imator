/// popup_colorpicker_draw()

// Saturation / Brightness picker
draw_sprite_general(spr_colorpicker, 0, 0, 0, 200, 200, dx, dy, 1, 1, 0, c_white, make_color_hsv(popup.hue, 255, 255), make_color_hsv(popup.hue, 255, 255), c_white, draw_get_alpha())
draw_box(dx, dy, 200, 200, true, c_black, 0.5)
draw_image(spr_point, 0, dx + (popup.saturation / 255) * 200, dy + (1 - popup.brightness / 255) * 200)
if (app_mouse_box(dx, dy, 200, 200))
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
	popup.saturation = floor((clamp((mouse_x - dx) / 200, 0, 1)) * 255)
	popup.brightness = floor((clamp(1 - (mouse_y - dy) / 200, 0, 1)) * 255)
	popup_colorpicker_update(null, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}

dx += 200 + 8

// Hue picker
draw_image(spr_colorpicker, 1, dx, dy)
draw_image(spr_colorpicker, 2, dx - 6, dy - 3+floor((1 - popup.hue / 255) * 200))
draw_box(dx, dy, 15, 200, true, c_black, 0.5)
if (window_focus = "colorpickerhuepick" && mouse_wheel <> 0)
{
	popup.hue = clamp(popup.hue + (-mouse_wheel) * 10, 0, 255)
	popup_colorpicker_update(null, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}

if (app_mouse_box(dx - 4, dy, 24, 200))
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
	popup.hue = floor(clamp(1 - (mouse_y - dy) / 200, 0, 1) * 255)
	popup_colorpicker_update(null, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}
dx += 20 + 8

// Preview
draw_box(dx, dy, 140, 20, false, popup.hsb_mode ? rgb_to_hsb(popup.color) : popup.color, 1)
draw_box(dx, dy, 140, 20, true, c_black, 0.5)
dy += 24 + 10

// Manual input
if (!popup.hsb_mode)
{
	if (draw_inputbox("colorpickerred", dx, dy, 60, "", popup.tbx_red, null, 24) && window_focus = string(popup.tbx_red))
	{
		popup.red = min(255, string_get_real(popup.tbx_red.text, 0))
		popup_colorpicker_update(popup.tbx_red, make_color_rgb(popup.red, popup.green, popup.blue), true)
	}
}

if (draw_inputbox("colorpickerhue", dx + (popup.hsb_mode ? 0 : 68), dy, 70, "", popup.tbx_hue, null, 30))
{
	popup.hue = min(255, string_get_real(popup.tbx_hue.text, 0))
	popup_colorpicker_update(popup.tbx_hue, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}

dy += 30
if (!popup.hsb_mode)
{
	if (draw_inputbox("colorpickergreen", dx, dy, 60, "", popup.tbx_green, null, 24) && window_focus = string(popup.tbx_green))
	{
		popup.green = min(255, string_get_real(popup.tbx_green.text, 0))
		popup_colorpicker_update(popup.tbx_green, make_color_rgb(popup.red, popup.green, popup.blue), true)
	}
}

if (draw_inputbox("colorpickersaturation", dx + (popup.hsb_mode ? 0 : 68), dy, 70, "", popup.tbx_saturation, null, 30))
{
	popup.saturation = min(255, string_get_real(popup.tbx_saturation.text, 0))
	popup_colorpicker_update(popup.tbx_saturation, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}

dy += 30
if (!popup.hsb_mode)
{
	if (draw_inputbox("colorpickerblue", dx, dy, 60, "", popup.tbx_blue, null, 24) && window_focus = string(popup.tbx_blue))
	{
		popup.blue = min(255, string_get_real(popup.tbx_blue.text, 0))
		popup_colorpicker_update(popup.tbx_blue, make_color_rgb(popup.red, popup.green, popup.blue), true)
	}
}

if (draw_inputbox("colorpickerbrightness", dx + (popup.hsb_mode ? 0 : 68), dy, 70, "", popup.tbx_brightness, null, 30))
{
	popup.brightness = min(255, string_get_real(popup.tbx_brightness.text, 0))
	popup_colorpicker_update(popup.tbx_brightness, make_color_hsv(popup.hue, popup.saturation, popup.brightness), false)
}

dy += 30 + 10
if (draw_inputbox("colorpickerhexadecimal", dx, dy, 100, "", popup.tbx_hexadecimal, null, 32))
	popup_colorpicker_update(popup.tbx_hexadecimal, hex_to_color(popup.tbx_hexadecimal.text), true)
dy += 30 + 10

// Reset
if (draw_button_normal("colorpickerreset", dx, dy, 100, 24))
	popup_colorpicker_update(null, popup.def, true)

// OK
dx = content_x + content_width / 2-50
dy = content_y + content_height - 32
if (draw_button_normal("colorpickerok", dx, dy, 100, 32)) 
	popup_close()
