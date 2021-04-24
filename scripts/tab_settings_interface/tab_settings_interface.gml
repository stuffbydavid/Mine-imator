/// tab_settings_interface()

function tab_settings_interface()
{
	// Color theme
	tab_control_togglebutton()
	togglebutton_add("settingsthemelight", null, theme_light, setting_theme = theme_light, action_setting_theme)
	togglebutton_add("settingsthemedark", null, theme_dark, setting_theme = theme_dark, action_setting_theme)
	togglebutton_add("settingsthemedarker", null, theme_darker, setting_theme = theme_darker, action_setting_theme)
	draw_togglebutton("settingstheme", dx, dy, true, true)
	tab_next()
	
	// Accent colors
	var accentboxx, accentboxy, accentboxw;
	accentboxx = dx
	accentboxy = dy + 22
	accentboxw = (dw - (7*4)) / 5
	
	tab_control((48 * 2) + 7 + 22)
	draw_label(text_get("settingsaccentcolor"), dx, accentboxy - 7, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	for (var i = 0; i < 10; i++)
	{
		if (draw_button_accent(accentboxx, accentboxy, accentboxw, 48, i) && i = 9)
		{
			// Set to custom accent
			colorpicker_show("settingsaccentcolor", setting_accent_custom, setting_accent_custom, action_setting_accent_custom, accentboxx, accentboxy, accentboxw, 48)
			update_interface_wait = true
		}
		
		accentboxx += accentboxw + 7
		
		if (i = 4)
		{
			accentboxx = dx
			accentboxy += 7 + 48
		}
	}
	tab_next()
	
	dy += 5
	
	// Language
	tab_control_menu()
	draw_button_menu("settingslanguage", e_menu.LIST, dx, dy, dw, 24, setting_language_filename, text_get("filelanguage"), null, false, null, null, text_get("filelocale"), null, null)
	tab_next()
	
	tab_control(24)
	if (draw_button_icon("settingslanguagefolder", dx, dy, 24, 24, false, icons.FOLDER, null, false, "tooltiplanguagefolder"))
		open_url(languages_directory)
	draw_button_icon("settingslanguageadd", dx + 24 + 4, dy, 24, 24, false, icons.PLUS, language_add, false, "tooltiplanguageadd")
	tab_next()
	
	// Realtime render
	tab_control_switch()
	draw_switch("settingsviewrealtimerender", dx, dy, setting_view_real_time_render, action_setting_view_real_time_render)
	tab_next()
	
	if (setting_view_real_time_render)
	{
		tab.interface.tbx_view_real_time_render_time.suffix = " " + text_get("settingsviewrealtimerendertimemilliseconds")
		
		tab_control_dragger()
		draw_dragger("settingsviewrealtimerendertime", dx, dy, dragger_width, setting_view_real_time_render_time, 1, 0, no_limit, 100, 1, tab.interface.tbx_view_real_time_render_time, action_setting_view_real_time_render_time)
		tab_next()
	}
	
	// Timeline
	tab_control_switch()
	draw_switch("settingstimelineautoscroll", dx, dy, setting_timeline_autoscroll, action_setting_timeline_autoscroll)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingstimelineselectjump", dx, dy, setting_timeline_select_jump, action_setting_timeline_select_jump)
	tab_next()
	
	// Z is up
	tab_control_switch()
	draw_switch("settingszisup", dx, dy, setting_z_is_up, action_setting_z_is_up)
	tab_next()
	
	// Camera
	tab_control_switch()
	draw_switch("settingssmoothcamera", dx, dy, setting_smooth_camera, action_setting_smooth_camera)
	tab_next()
	
	// Variant search
	tab_control_switch()
	draw_switch("settingssearchvariants", dx, dy, setting_search_variants, action_setting_search_variants)
	tab_next()
}
