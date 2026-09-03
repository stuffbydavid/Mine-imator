/// tab_settings_interface()

function tab_settings_interface()
{
	dy += label_height + 6
	draw_label(text_get("settingsappearance"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
	dy += 8
	
	// Color theme
	tab_control_togglebutton()
	togglebutton_add("settingsthemelight", null, theme_light, setting_theme = theme_light, action_setting_theme)
	togglebutton_add("settingsthemedark", null, theme_dark, setting_theme = theme_dark, action_setting_theme)
	togglebutton_add("settingsthemedarker", null, theme_darker, setting_theme = theme_darker, action_setting_theme)
	draw_togglebutton("settingstheme", dx, dy, true, true)
	tab_next()
	
	// Accent colors
	var accentboxx, accentboxy, accentboxw, accentboxh;
	accentboxx = dx
	accentboxy = dy + 22
	accentboxw = (dw - (7*4)) / 5
	accentboxh = app.panel_compact ? 24 : 48
	
	tab_control((accentboxh * 2) + 7 + 22)
	draw_label(text_get("settingsaccentcolor"), dx, accentboxy - 7, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	for (var i = 0; i < 10; i++)
	{
		if (draw_button_accent(accentboxx, accentboxy, accentboxw, accentboxh, i) && i = 9)
		{
			// Set to custom accent
			colorpicker_show("settingsaccentcolor", setting_accent_custom, setting_accent_custom, action_setting_accent_custom, accentboxx, accentboxy, accentboxw, accentboxh)
			update_interface_timeout = current_time + 10000
			update_interface_wait = true
		}
		
		accentboxx += accentboxw + 7
		
		if (i = 4)
		{
			accentboxx = dx
			accentboxy += 7 + accentboxh
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
	
	// Scale
	if (interface_scale_default_get() > 1)
	{
		tab_control_switch()
		draw_switch("settingsinterfacescaleauto", dx, dy, setting_interface_scale_auto, action_setting_interface_scale_auto, "settingsinterfacescaleautotip")
		tab_next()
	
		if (!setting_interface_scale_auto)
		{
			tab_control_menu()
			draw_button_menu("settingsinterfacescale", e_menu.LIST, dx, dy, dw, 24, setting_interface_scale, string(setting_interface_scale * 100) + "%", action_setting_interface_scale)
			tab_next()
		}
	}
	
	tab_control_switch()
	draw_switch("settingscompact", dx, dy, setting_interface_compact, action_setting_interface_compact)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingscompacttimeline", dx, dy, setting_timeline_compact, action_setting_timeline_compact)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingsreducedmotion", dx, dy, setting_reduced_motion, action_setting_reduced_motion)
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settingstimeline"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
	dy += 8
	
	// Timeline
	tab_control_switch()
	draw_switch("settingstimelineautoscroll", dx, dy, setting_timeline_autoscroll, action_setting_timeline_autoscroll)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingstimelineselectjump", dx, dy, setting_timeline_select_jump, action_setting_timeline_select_jump)
	tab_next()
	
	tab_control_switch()
	draw_switch("settingstimelineframesnap", dx, dy, setting_timeline_frame_snap, action_setting_timeline_frame_snap, "settingstimelineframesnaptip")
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settingstools"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
	dy += 8
	
	// Z is up
	tab_control_switch()
	draw_switch("settingszisup", dx, dy, setting_z_is_up, action_setting_z_is_up)
	tab_next()
	
	// Separate tool modes
	tab_control_switch()
	draw_switch("settingsseparatetoolmodes", dx, dy, setting_separate_tool_modes, action_setting_separate_tool_modes, "settingsseparatetoolmodestip")
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settingsviewport"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
	dy += 8
	
	// Gizmos face camera
	tab_control_switch()
	draw_switch("settingsgizmosfacecamera", dx, dy, setting_gizmos_face_camera, action_setting_gizmos_face_camera)
	tab_next()
	
	// Fade gizmos
	tab_control_switch()
	draw_switch("settingsfadegizmos", dx, dy, setting_fade_gizmos, action_setting_fade_gizmos)
	tab_next()
	
	// Lock mouse
	tab_control_switch()
	draw_switch("settingscameralockmouse", dx, dy, setting_camera_lock_mouse, action_setting_camera_lock_mouse)
	tab_next()
	
	// Place new objects
	tab_control_switch()
	draw_switch("settingsplacenew", dx, dy, setting_place_new, action_setting_place_new)
	tab_next()
}
