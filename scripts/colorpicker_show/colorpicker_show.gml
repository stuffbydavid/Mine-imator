/// colorpicker_show(name, color, default, script, x, y, width, height)
/// @arg name
/// @arg color
/// @arg default
/// @arg script
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function colorpicker_show(name, color, def, script, xx, yy, width, height)
{
	if (settings_menu_name = "colorpicker" && colorpicker.value_script = script)
		popup_close()
	else
	{
		settings_menu_busy_prev = window_busy
		window_busy = "settingsmenu"
		window_focus = ""
		app_mouse_clear()
		
		settings_menu_name = "colorpicker"
		settings_menu_ani = 0
		settings_menu_ani_type = "show"
		
		settings_menu_primary = false
		settings_menu_x = xx
		settings_menu_y = yy
		
		if (settings_menu_x < 0)
			settings_menu_x = xx + width + 8
		
		if (settings_menu_x + 192 > window_width)
			settings_menu_x = window_width - 192
		
		settings_menu_button_h = height
		settings_menu_above = false
		settings_menu_steps = 0
		settings_menu_script = colorpicker_draw
		
		colorpicker.value_name = name
		colorpicker.value_script = script
		colorpicker.mode = "rgb"
		
		colorpicker.def = def
		colorpicker.color = color
		colorpicker.red = color_get_red(color)
		colorpicker.green = color_get_green(color)
		colorpicker.blue = color_get_blue(color)
		
		colorpicker.hue = color_get_hue(color)
		colorpicker.saturation = color_get_saturation(color)
		colorpicker.brightness = color_get_value(color)
		
		colorpicker.tbx_red.text = string(colorpicker.red)
		colorpicker.tbx_green.text = string(colorpicker.green)
		colorpicker.tbx_blue.text = string(colorpicker.blue)
		colorpicker.tbx_hexadecimal.text = color_to_hex(color)
	}
}
