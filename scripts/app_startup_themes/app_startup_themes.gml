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
	
	var theme_edit;
	
	#region Light theme
	theme_light = new_obj(obj_theme);
	theme_edit = theme_light
	
	theme_edit.name = "light"
	theme_edit.dark = false
	theme_edit.pattern = 0
	theme_edit.accent_list = array()
	array_add(theme_edit.accent_list, hex_to_color("DB3030"))
	array_add(theme_edit.accent_list, hex_to_color("D85B00"))
	array_add(theme_edit.accent_list, hex_to_color("D68E02"))
	array_add(theme_edit.accent_list, hex_to_color("34A100"))
	array_add(theme_edit.accent_list, hex_to_color("0D8E41"))
	array_add(theme_edit.accent_list, hex_to_color("048E8E"))
	array_add(theme_edit.accent_list, hex_to_color("2144F1"))
	array_add(theme_edit.accent_list, hex_to_color("982BCB"))
	array_add(theme_edit.accent_list, hex_to_color("E93983"))
	
	theme_edit.level_top = c_white
	theme_edit.level_middle = hex_to_color("FAFAFA")
	theme_edit.level_bottom = hex_to_color("F2F2F2")
	theme_edit.viewport_top = hex_to_color("F0FFFF")
	theme_edit.viewport_bottom = hex_to_color("B5E8F2")
	
	theme_edit.text_main = hex_to_color("000000")
	theme_edit.text_secondary = theme_edit.text_main
	theme_edit.text_tertiary = theme_edit.text_main
	theme_edit.border = theme_edit.text_main
	theme_edit.overlay = theme_edit.text_main
	theme_edit.button_text = hex_to_color("FFFFFF")
	theme_edit.button_text_alpha = .91
	theme_edit.dark_overlay_alpha = .15
	
	// Other colors
	theme_edit.red_error = hex_to_color("FF1D0F")
	theme_edit.yellow_warning = hex_to_color("FFC01E")
	theme_edit.green_success = hex_to_color("61C159")
	theme_edit.red = hex_to_color("FF5656")
	theme_edit.green = hex_to_color("4AB758")
	theme_edit.blue = hex_to_color("1370FB")
	theme_edit.pink = hex_to_color("FF5FFF")
	theme_edit.cyan = hex_to_color("51C2FF")
	theme_edit.yellow = hex_to_color("FFD969")
	theme_edit.magenta = hex_to_color("FF37E8")
	
	theme_edit.toast_color[e_toast.INFO] = hex_to_color("158AF5")
	theme_edit.toast_color[e_toast.POSITIVE] = hex_to_color("64A56B")
	theme_edit.toast_color[e_toast.WARNING] = hex_to_color("D09522")
	theme_edit.toast_color[e_toast.NEGATIVE] = hex_to_color("FF1D0F")
	
	#endregion
	
	#region Dark theme
	theme_dark = new_obj(obj_theme);
	theme_edit = theme_dark
	
	theme_edit.name = "dark"
	theme_edit.dark = true
	theme_edit.pattern = 0
	theme_edit.accent_list = array()
	array_add(theme_edit.accent_list, hex_to_color("FF7E76"))
	array_add(theme_edit.accent_list, hex_to_color("FFA360"))
	array_add(theme_edit.accent_list, hex_to_color("FFF065"))
	array_add(theme_edit.accent_list, hex_to_color("8BFF6D"))
	array_add(theme_edit.accent_list, hex_to_color("4EF390"))
	array_add(theme_edit.accent_list, hex_to_color("49EED9"))
	array_add(theme_edit.accent_list, hex_to_color("98BBFF"))
	array_add(theme_edit.accent_list, hex_to_color("DF9CFF"))
	array_add(theme_edit.accent_list, hex_to_color("FF9BC5"))
	
	theme_edit.level_top = hex_to_color("37444A")
	theme_edit.level_middle = hex_to_color("2B373D")
	theme_edit.level_bottom = hex_to_color("18242A")
	theme_edit.viewport_top = hex_to_color("2B373D")
	theme_edit.viewport_bottom = hex_to_color("839096")
	
	theme_edit.text_main = hex_to_color("FFFFFF")
	theme_edit.text_secondary = theme_edit.text_main
	theme_edit.text_tertiary = theme_edit.text_main
	theme_edit.border = theme_edit.text_main
	theme_edit.overlay = theme_edit.text_main
	theme_edit.button_text = hex_to_color("000000")
	theme_edit.button_text_alpha = .91
	theme_edit.dark_overlay_alpha = .25
	
	// Other colors
	theme_edit.red_error = hex_to_color("FF7A72")
	theme_edit.yellow_warning = hex_to_color("FFEB36")
	theme_edit.green_success = hex_to_color("64E879")
	theme_edit.red = hex_to_color("FF5656")
	theme_edit.green = hex_to_color("23FF88")
	theme_edit.blue = hex_to_color("1370FB")
	theme_edit.pink = hex_to_color("FF5FFF")
	theme_edit.cyan = hex_to_color("51C2FF")
	theme_edit.yellow = hex_to_color("FFD969")
	theme_edit.magenta = hex_to_color("FF37E8")
	
	theme_edit.toast_color[e_toast.INFO] = hex_to_color("7EC1FF")
	theme_edit.toast_color[e_toast.POSITIVE] = hex_to_color("64E879")
	theme_edit.toast_color[e_toast.WARNING] = hex_to_color("FFEB36")
	theme_edit.toast_color[e_toast.NEGATIVE] = hex_to_color("FF7A72")
	
	#endregion
	
	#region Darker theme
	theme_darker = new_obj(obj_theme);
	theme_edit = theme_darker
	
	theme_edit.name = "darker"
	theme_edit.dark = true
	theme_edit.pattern = 0
	theme_edit.accent_list = array()
	array_add(theme_edit.accent_list, hex_to_color("FF7E76"))
	array_add(theme_edit.accent_list, hex_to_color("FFA360"))
	array_add(theme_edit.accent_list, hex_to_color("FFF065"))
	array_add(theme_edit.accent_list, hex_to_color("8BFF6D"))
	array_add(theme_edit.accent_list, hex_to_color("4EF390"))
	array_add(theme_edit.accent_list, hex_to_color("49EED9"))
	array_add(theme_edit.accent_list, hex_to_color("98BBFF"))
	array_add(theme_edit.accent_list, hex_to_color("DF9CFF"))
	array_add(theme_edit.accent_list, hex_to_color("FF9BC5"))
	
	theme_edit.level_top = hex_to_color("1C1C1C")
	theme_edit.level_middle = hex_to_color("101010")
	theme_edit.level_bottom = hex_to_color("050505")
	theme_edit.viewport_top = hex_to_color("484848")
	theme_edit.viewport_bottom = hex_to_color("2B2B2B")
	
	theme_edit.text_main = hex_to_color("FFFFFF")
	theme_edit.text_secondary = theme_edit.text_main
	theme_edit.text_tertiary = theme_edit.text_main
	theme_edit.border = theme_edit.text_main
	theme_edit.overlay = theme_edit.text_main
	theme_edit.button_text = hex_to_color("000000")
	theme_edit.button_text_alpha = .91
	theme_edit.dark_overlay_alpha = .65
	
	// Other colors
	theme_edit.red_error = hex_to_color("FF7A72")
	theme_edit.yellow_warning = hex_to_color("FFEB36")
	theme_edit.green_success = hex_to_color("64E879")
	theme_edit.red = hex_to_color("FF5656")
	theme_edit.green = hex_to_color("23FF88")
	theme_edit.blue = hex_to_color("1370FB")
	theme_edit.pink = hex_to_color("FF5FFF")
	theme_edit.cyan = hex_to_color("51C2FF")
	theme_edit.yellow = hex_to_color("FFD969")
	theme_edit.magenta = hex_to_color("FF37E8")
	
	theme_edit.toast_color[e_toast.INFO] = hex_to_color("7EC1FF")
	theme_edit.toast_color[e_toast.POSITIVE] = hex_to_color("64E879")
	theme_edit.toast_color[e_toast.WARNING] = hex_to_color("FFEB36")
	theme_edit.toast_color[e_toast.NEGATIVE] = hex_to_color("FF7A72")
	
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
