/// interface_update()
/// @desc Updates interface colors based on selected theme

/*

function color_ease(color, colorgoal)
{
	var rgb_old, rgb_new;
	rgb_old = [color_get_red(color), color_get_green(color), color_get_blue(color)]
	rgb_new = [color_get_red(colorgoal), color_get_green(colorgoal), color_get_blue(colorgoal)]
	
	for (var i = 0; i <= 2; i++)
		rgb_old[i] += (rgb_new[i] - rgb_old[i]) / max(1, 4 / delta)
	
	return make_color_rgb(rgb_old[0], rgb_old[1], rgb_old[2])
}

function alpha_ease(old, goal)
{
	return old + (goal - old) / max(1, 4 / delta)
}

function interface_update()
{
	with (setting_theme)
	{
		c_text_main = color_ease(c_text_main, text_main)
		c_text_secondary = color_ease(c_text_secondary, text_secondary)
		c_text_tertiary = color_ease(c_text_tertiary, text_tertiary)
		c_border = color_ease(c_border, border)
		c_overlay = color_ease(c_overlay, overlay)
		c_button_text = color_ease(c_button_text, button_text)
		a_button_text = alpha_ease(a_button_text, button_text_alpha)
		a_dark_overlay = alpha_ease(a_dark_overlay, dark_overlay_alpha)
		
		c_level_top = color_ease(c_level_top, level_top)
		c_level_middle = color_ease(c_level_middle, level_middle)
		c_level_bottom = color_ease(c_level_bottom, level_bottom)
		c_viewport_top = color_ease(c_viewport_top, viewport_top)
		c_viewport_bottom = color_ease(c_viewport_bottom, viewport_bottom)
		c_error = color_ease(c_error, red_error)
		c_warning = color_ease(c_warning, yellow_warning)
		c_success = color_ease(c_success, green_success)
		c_axisred = color_ease(c_axisred, red)
		c_axisgreen = color_ease(c_axisgreen, green)
		c_axisblue = color_ease(c_axisblue, blue)
		c_bend = color_ease(c_bend, pink)
		
		c_axiscyan = color_ease(c_axiscyan, cyan)
		c_axisyellow = color_ease(c_axisyellow, yellow)
		c_axismagenta = color_ease(c_axismagenta, magenta)
		
		// Accent color(s)
		if (app.setting_accent = 9)
			c_accent = color_ease(c_accent, app.setting_accent_custom)
		else
			c_accent = color_ease(c_accent, accent_list[app.setting_accent])
	}
	
	interface_update_accent()
}
*/