/// app_startup_themes()

function app_startup_themes()
{
	// Themes
	globalvar theme_classic, theme_light, theme_dark, theme_darker;
	
	// Colors used in interface
	globalvar c_accent, a_accent, c_accent_hover, a_accent_hover, c_accent_pressed, a_accent_pressed, c_hover, a_hover, c_accent_overlay, a_accent_overlay;
	globalvar c_text_main, a_text_main, c_text_secondary, a_text_secondary, c_text_tertiary, a_text_tertiary;
	globalvar c_border, a_border, c_overlay, a_overlay, a_dark_overlay;
	globalvar c_level_top, c_level_middle, c_level_bottom, c_input_background, c_button_text, a_button_text;
	globalvar c_info, c_success, c_warning, c_error, c_axisred, c_axisgreen, c_axisblue, c_axiscyan, c_axisyellow, c_axismagenta;
	//globalvar c_viewport_top, c_viewport_bottom, c_bend;
	globalvar c_control_red, c_control_green, c_control_blue, c_control_cyan, c_control_yellow, c_control_magenta, c_control_white;
	
	update_interface_timeout = current_time
	update_interface_wait = false
	
	// Alphas
	a_accent = 1
	a_accent_hover = 1
	a_accent_pressed = 1
	a_hover = .45
	a_accent_overlay = .15
	
	a_text_main = .9
	a_text_secondary = .6
	a_text_tertiary = .35
	
	a_border = .15
	a_overlay = .05
	
	#region Classic theme
	
	theme_classic = new_obj(obj_theme)
	
	with (theme_classic)
	{
		name = "classic"
		dark = false
		pattern = 0
		accent_list = array()
		
		var satdec, satdec2, valdec;
		satdec = 5
		satdec2 = 20
		valdec = 10
		array_add(accent_list, make_color_hsv(0, 199 - satdec, 219 - valdec))
		array_add(accent_list, make_color_hsv(18, 255 - satdec, 216 - valdec))
		array_add(accent_list, make_color_hsv(28, 253 - satdec, 214 - valdec))
		array_add(accent_list, make_color_hsv(71, 255 - satdec, 161 - valdec))
		array_add(accent_list, make_color_hsv(71, 182, 123))
		array_add(accent_list, make_color_hsv(128, 248 - satdec, 142 - valdec))
		array_add(accent_list, make_color_hsv(170, 141, 215))
		array_add(accent_list, make_color_hsv(199, 201 - satdec, 203 - valdec))
		array_add(accent_list, make_color_hsv(237, 193 - satdec, 233 - valdec))
		
		var lighttop = make_color_hsv(145, 5, 252);
		var lightmid = make_color_hsv(145, 5, 241);
		var lightbot = make_color_hsv(139, 12, 226);
		
		var mi1top = make_color_rgb(200, 200, 200);
		var mi1mid = make_color_rgb(180, 180, 180);
		var mi1bot = make_color_rgb(153, 153, 153);
		
		var perc = 0.25;
		level_top = merge_color(mi1top, lighttop, perc)
		level_middle = merge_color(mi1mid, lightmid, perc)
		level_bottom = merge_color(mi1bot, lightbot, perc)
		input_background = merge_color(level_top, c_white, 0.25)
		
		var lighttext = make_color_hsv(140, 89, 20);
		var mi1text = make_color_hsv(73, 5, 6);
		text_main = merge_color(mi1text, lighttext, perc)
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = c_red
		button_text = hex_to_color("FFFFFF")
		button_text_alpha = .91
		dark_overlay_alpha = .15
		
		// Other colors
		satdec = 5
		valdec = 5
		red = make_color_hsv(0, 169 - satdec, 255 - valdec)
		green = make_color_hsv(90, 152 - satdec, 183 - valdec)
		blue = make_color_hsv(153, 236 - satdec, 251 - valdec)
		cyan = make_color_hsv(142, 174 - satdec, 255 - valdec)
		yellow = make_color_hsv(31, 158 - satdec, 244 - valdec)
		magenta = make_color_hsv(217, 200 - satdec, 255 - valdec)
		//pink = make_color_hsv(212, 160, 255)
		
		satdec = 5
		valdec = 5
		toast_color[e_toast.INFO] = make_color_hsv(148, 233 - satdec, 245 - valdec)
		toast_color[e_toast.POSITIVE] = make_color_hsv(90, 100 - satdec, 165 - valdec) //make_color_hsv(82, 137, 193)
		toast_color[e_toast.WARNING] = make_color_hsv(28, 213 - satdec, 208 - valdec) //make_color_hsv(31, 225, 255)
		toast_color[e_toast.NEGATIVE] = make_color_hsv(2, 240 - satdec, 255 - valdec)
	}
	
	#endregion
	
	#region Light theme
	
	theme_light = new_obj(obj_theme)
	
	with (theme_light)
	{
		name = "light"
		dark = false
		pattern = 0
		accent_list = array()
		
		array_add(accent_list, make_color_hsv(0, 199, 219))
		array_add(accent_list, make_color_hsv(18, 255, 216))
		array_add(accent_list, make_color_hsv(28, 253, 214))
		array_add(accent_list, make_color_hsv(71, 255, 161))
		array_add(accent_list, make_color_hsv(102, 232, 142))
		array_add(accent_list, make_color_hsv(128, 248, 142))
		array_add(accent_list, make_color_hsv(173, 136, 205))
		array_add(accent_list, make_color_hsv(199, 201, 203))
		array_add(accent_list, make_color_hsv(237, 193, 233))
		
		level_top = make_color_hsv(145, 5, 252);
		level_middle = make_color_hsv(145, 5, 241);
		level_bottom = make_color_hsv(139, 12, 226);
		input_background = level_top
		
		text_main = make_color_hsv(140, 89, 20)
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("FFFFFF")
		button_text_alpha = .91
		dark_overlay_alpha = .15
		
		// Other colors
		red = make_color_hsv(0, 169, 255)
		green = make_color_hsv(90, 152, 183)
		blue = make_color_hsv(153, 236, 251)
		cyan = make_color_hsv(142, 174, 255)
		yellow = make_color_hsv(31, 158, 244)
		magenta = make_color_hsv(217, 200, 255)
		//pink = make_color_hsv(212, 160, 255)
		
		toast_color[e_toast.INFO] = make_color_hsv(148, 233, 245)
		toast_color[e_toast.POSITIVE] = make_color_hsv(90, 100, 165) //make_color_hsv(82, 137, 193)
		toast_color[e_toast.WARNING] = make_color_hsv(28, 213, 208) //make_color_hsv(31, 225, 255)
		toast_color[e_toast.NEGATIVE] = make_color_hsv(2, 240, 255)
	}
	
	#endregion
	
	#region Dark theme
	theme_dark = new_obj(obj_theme)
	
	with (theme_dark)
	{
		name = "dark"
		dark = true
		pattern = 0
		accent_list = array()
		array_add(accent_list, make_color_hsv(2, 137, 255))
		array_add(accent_list, make_color_hsv(18, 159, 255))
		array_add(accent_list, make_color_hsv(38, 154, 255))
		array_add(accent_list, make_color_hsv(76, 146, 255))
		array_add(accent_list, make_color_hsv(102, 173, 243))
		array_add(accent_list, make_color_hsv(122, 177, 238))
		array_add(accent_list, make_color_hsv(156, 103, 255))
		array_add(accent_list, make_color_hsv(199, 99, 255))
		array_add(accent_list, make_color_hsv(237, 100, 255))
		
		level_top = make_color_hsv(141, 65, 74)
		level_middle = make_color_hsv(142, 75, 61)
		level_bottom = make_color_hsv(142, 109, 42)
		input_background = level_top
		//viewport_top = make_color_hsv(142, 75, 61)
		//viewport_bottom = make_color_hsv(141, 32, 150)
		
		text_main = make_color_hsv(0, 0, 255)
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("000000")
		button_text_alpha = .91
		dark_overlay_alpha = .25
		
		// Other colors
		red = make_color_hsv(0, 169, 255)
		green = make_color_hsv(105, 220, 255)
		blue = make_color_hsv(153, 236, 251)
		cyan = make_color_hsv(142, 174, 255)
		yellow = make_color_hsv(32, 150, 255)
		magenta = make_color_hsv(217, 200, 255)
		//pink = make_color_hsv(212, 160, 255)
		
		toast_color[e_toast.INFO] = make_color_hsv(148, 129, 255)
		toast_color[e_toast.POSITIVE] = make_color_hsv(92, 145, 232)
		toast_color[e_toast.WARNING] = make_color_hsv(38, 201, 255)
		toast_color[e_toast.NEGATIVE] = make_color_hsv(2, 141, 255)
	}
	
	#endregion
	
	#region Darker theme
	theme_darker = new_obj(obj_theme)
	
	with (theme_darker)
	{
		name = "darker"
		dark = true
		pattern = 0
		accent_list = array()
		
		array_add(accent_list, make_color_hsv(2, 137, 255))
		array_add(accent_list, make_color_hsv(18, 159, 255))
		array_add(accent_list, make_color_hsv(38, 154, 255))
		array_add(accent_list, make_color_hsv(76, 146, 255))
		array_add(accent_list, make_color_hsv(102, 173, 243))
		array_add(accent_list, make_color_hsv(122, 177, 238))
		array_add(accent_list, make_color_hsv(156, 103, 255))
		array_add(accent_list, make_color_hsv(199, 99, 255))
		array_add(accent_list, make_color_hsv(237, 100, 255))
		
		var valinc = 5;
		level_top = make_color_hsv(0, 0, 28 + valinc)
		level_middle = make_color_hsv(0, 0, 16 + valinc)
		level_bottom = make_color_hsv(0, 0, 5 + valinc)
		input_background = level_top
		//viewport_top = make_color_hsv(0, 0, 72)
		//viewport_bottom = make_color_hsv(0, 0, 43)
		
		text_main = make_color_hsv(0, 0, 255)
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("000000")
		button_text_alpha = .91
		dark_overlay_alpha = .65
		
		// Other colors
		red = make_color_hsv(0, 169, 255)
		green = make_color_hsv(105, 220, 255)
		blue = make_color_hsv(153, 236, 251)
		cyan = make_color_hsv(142, 174, 255)
		yellow = make_color_hsv(32, 150, 255)
		magenta = make_color_hsv(217, 200, 255)
		//pink = make_color_hsv(212, 160, 255)
		
		toast_color[e_toast.INFO] = make_color_hsv(148, 129, 255)
		toast_color[e_toast.POSITIVE] = make_color_hsv(92, 145, 232)
		toast_color[e_toast.WARNING] = make_color_hsv(38, 201, 255)
		toast_color[e_toast.NEGATIVE] = make_color_hsv(2, 141, 255)
	}
	
	#endregion
	
	// View controls use darker theme colors for contrast
	c_control_red = theme_darker.red
	c_control_green = theme_darker.green
	c_control_blue = theme_darker.blue
	c_control_cyan = theme_darker.cyan
	c_control_yellow = theme_darker.yellow
	c_control_magenta = theme_darker.magenta
	c_control_white = theme_light.level_middle
}
