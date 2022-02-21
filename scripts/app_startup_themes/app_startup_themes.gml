/// app_startup_themes()

function app_startup_themes()
{
	// Themes
	globalvar theme_light, theme_dark, theme_darker;
	
	// Colors used in interface
	globalvar c_accent, a_accent, c_accent_hover, a_accent_hover, c_accent_pressed, a_accent_pressed, c_hover, a_hover, c_accent_overlay, a_accent_overlay;
	globalvar c_text_main, a_text_main, c_text_secondary, a_text_secondary, c_text_tertiary, a_text_tertiary;
	globalvar c_border, a_border, c_overlay, a_overlay, a_dark_overlay;
	globalvar c_level_top, c_level_middle, c_level_bottom, c_button_text, a_button_text;
	globalvar c_viewport_top, c_viewport_bottom, c_error, c_warning, c_success, c_axisred, c_axisgreen, c_axisblue, c_axiscyan, c_axisyellow, c_axismagenta, c_bend;
	globalvar c_control_red, c_control_green, c_control_blue, c_control_cyan, c_control_yellow, c_control_magenta, c_control_magenta, c_control_white;
	
	update_interface_wait = false
	
	// Alphas
	a_accent = 1
	a_accent_hover = 1
	a_accent_pressed = 1
	a_hover = .45
	a_accent_overlay = .10
	
	a_text_main = .9
	a_text_secondary = .6
	a_text_tertiary = .35
	
	a_border = .15
	a_overlay = .05
	
	#region Light theme
	
	theme_light = new_obj(obj_theme)
	
	with (theme_light)
	{
		name = "light"
		dark = false
		pattern = 0
		accent_list = array()
		array_add(accent_list, hex_to_color("DB3030"))
		array_add(accent_list, hex_to_color("D85B00"))
		array_add(accent_list, hex_to_color("D68E02"))
		array_add(accent_list, hex_to_color("34A100"))
		array_add(accent_list, hex_to_color("0D8E41"))
		array_add(accent_list, hex_to_color("048E8E"))
		array_add(accent_list, hex_to_color("2144F1"))
		array_add(accent_list, hex_to_color("982BCB"))
		array_add(accent_list, hex_to_color("E93983"))
		
		level_top = hex_to_color("F7FAFC")
		level_middle = hex_to_color("ECEFF1")
		level_bottom = hex_to_color("D7DFE2")
		viewport_top = hex_to_color("F0FFFF")
		viewport_bottom = hex_to_color("B5E8F2")
		
		text_main = hex_to_color("0D1214")
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("FFFFFF")
		button_text_alpha = .91
		dark_overlay_alpha = .15
		
		// Other colors
		red_error = hex_to_color("FF1D0F")
		yellow_warning = hex_to_color("FFC01E")
		green_success = hex_to_color("61C159")
		red = hex_to_color("FF5656")
		green = hex_to_color("4AB758")
		blue = hex_to_color("1370FB")
		pink = hex_to_color("FF5FFF")
		cyan = hex_to_color("51C2FF")
		yellow = hex_to_color("FFD969")
		magenta = hex_to_color("FF37E8")
		
		toast_color[e_toast.INFO] = hex_to_color("158AF5")
		toast_color[e_toast.POSITIVE] = hex_to_color("64A56B")
		toast_color[e_toast.WARNING] = hex_to_color("D09522")
		toast_color[e_toast.NEGATIVE] = hex_to_color("FF1D0F")
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
		array_add(accent_list, hex_to_color("FF7E76"))
		array_add(accent_list, hex_to_color("FFA360"))
		array_add(accent_list, hex_to_color("FFF065"))
		array_add(accent_list, hex_to_color("8BFF6D"))
		array_add(accent_list, hex_to_color("4EF390"))
		array_add(accent_list, hex_to_color("49EED9"))
		array_add(accent_list, hex_to_color("98BBFF"))
		array_add(accent_list, hex_to_color("DF9CFF"))
		array_add(accent_list, hex_to_color("FF9BC5"))
		
		level_top = hex_to_color("37444A")
		level_middle = hex_to_color("2B373D")
		level_bottom = hex_to_color("18242A")
		viewport_top = hex_to_color("2B373D")
		viewport_bottom = hex_to_color("839096")
		
		text_main = hex_to_color("FFFFFF")
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("000000")
		button_text_alpha = .91
		dark_overlay_alpha = .25
		
		// Other colors
		red_error = hex_to_color("FF7A72")
		yellow_warning = hex_to_color("FFEB36")
		green_success = hex_to_color("64E879")
		red = hex_to_color("FF5656")
		green = hex_to_color("23FF88")
		blue = hex_to_color("1370FB")
		pink = hex_to_color("FF5FFF")
		cyan = hex_to_color("51C2FF")
		yellow = hex_to_color("FFD969")
		magenta = hex_to_color("FF37E8")
		
		toast_color[e_toast.INFO] = hex_to_color("7EC1FF")
		toast_color[e_toast.POSITIVE] = hex_to_color("64E879")
		toast_color[e_toast.WARNING] = hex_to_color("FFEB36")
		toast_color[e_toast.NEGATIVE] = hex_to_color("FF7A72")
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
		array_add(accent_list, hex_to_color("FF7E76"))
		array_add(accent_list, hex_to_color("FFA360"))
		array_add(accent_list, hex_to_color("FFF065"))
		array_add(accent_list, hex_to_color("8BFF6D"))
		array_add(accent_list, hex_to_color("4EF390"))
		array_add(accent_list, hex_to_color("49EED9"))
		array_add(accent_list, hex_to_color("98BBFF"))
		array_add(accent_list, hex_to_color("DF9CFF"))
		array_add(accent_list, hex_to_color("FF9BC5"))
		
		level_top = hex_to_color("1C1C1C")
		level_middle = hex_to_color("101010")
		level_bottom = hex_to_color("050505")
		viewport_top = hex_to_color("484848")
		viewport_bottom = hex_to_color("2B2B2B")
		
		text_main = hex_to_color("FFFFFF")
		text_secondary = text_main
		text_tertiary = text_main
		border = text_main
		overlay = text_main
		button_text = hex_to_color("000000")
		button_text_alpha = .91
		dark_overlay_alpha = .65
		
		// Other colors
		red_error = hex_to_color("FF7A72")
		yellow_warning = hex_to_color("FFEB36")
		green_success = hex_to_color("64E879")
		red = hex_to_color("FF5656")
		green = hex_to_color("23FF88")
		blue = hex_to_color("1370FB")
		pink = hex_to_color("FF5FFF")
		cyan = hex_to_color("51C2FF")
		yellow = hex_to_color("FFD969")
		magenta = hex_to_color("FF37E8")
		
		toast_color[e_toast.INFO] = hex_to_color("7EC1FF")
		toast_color[e_toast.POSITIVE] = hex_to_color("64E879")
		toast_color[e_toast.WARNING] = hex_to_color("FFEB36")
		toast_color[e_toast.NEGATIVE] = hex_to_color("FF7A72")
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
