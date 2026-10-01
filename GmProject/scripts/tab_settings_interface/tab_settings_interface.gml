function tab_settings_interface()
{
	dy += label_height + 6
	draw_label(text_get("settings/appearance"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
	dy += 8
	
	// Color theme
	tab_control_togglebutton(2)
	togglebutton_add("settings/theme/classic", null, theme_classic, setting_theme = theme_classic, action_setting_theme)
	togglebutton_add("settings/theme/light", null, theme_light, setting_theme = theme_light, action_setting_theme)
	togglebutton_add("settings/theme/dark", null, theme_dark, setting_theme = theme_dark, action_setting_theme)
	togglebutton_add("settings/theme/darker", null, theme_darker, setting_theme = theme_darker, action_setting_theme)
	draw_togglebutton("settings/theme", dx, dy, true, true)
	tab_next()
	
	// Accent colors
	var accentboxx, accentboxy, accentboxw, accentboxh;
	accentboxx = dx
	accentboxy = dy + 22
	accentboxw = (dw - (7*4)) / 5
	accentboxh = app.panel_compact ? 24 : 48
	
	tab_control((accentboxh * 2) + 7 + 22)
	draw_label(text_get("settings/accent_color"), dx, accentboxy - 7, fa_left, fa_bottom, c_text_secondary, a_text_secondary, font_label)
	
	for (var i = 0; i < 10; i++)
	{
		if (draw_button_accent(accentboxx, accentboxy, accentboxw, accentboxh, i) && i = 9)
		{
			// Set to custom accent
			colorpicker_show("settings/accent_color", setting_accent_custom, setting_accent_custom, action_setting_accent_custom, accentboxx, accentboxy, accentboxw, accentboxh)
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
	draw_button_menu("settings/language", e_menu.LIST, dx, dy, dw, 24, setting_language_filename, text_get("file/language"), null, false, null, null, text_get("file/locale"), null, null)
	tab_next()
	
	tab_control(24)
	if (draw_button_icon("settings/languagefolder", dx, dy, 24, 24, false, icons.FOLDER, null, false, "tooltip/language_folder"))
		open_url(languages_directory)
	draw_button_icon("settings/languageadd", dx + 24 + 4, dy, 24, 24, false, icons.PLUS, language_add, false, "tooltip/language_add")
	tab_next()
	
	// Scale
	if (interface_scale_default_get() > 1)
	{
		tab_control_switch()
		draw_switch("settings/interface_scale_auto", dx, dy, setting_interface_scale_auto, action_setting_interface_scale_auto, "settings/interface_scale_auto_tip")
		tab_next()
	
		if (!setting_interface_scale_auto)
		{
			tab_control_menu()
			draw_button_menu("settings/interface_scale", e_menu.LIST, dx, dy, dw, 24, setting_interface_scale, string(setting_interface_scale * 100) + "%", action_setting_interface_scale)
			tab_next()
		}
	}
	
	tab_control_switch()
	draw_switch("settings/compact", dx, dy, setting_interface_compact, action_setting_interface_compact)
	tab_next()
	
	tab_control_switch()
	draw_switch("settings/compact_timeline", dx, dy, setting_timeline_compact, action_setting_timeline_compact)
	tab_next()
	
	tab_control_switch()
	draw_switch("settings/reduced_motion", dx, dy, setting_reduced_motion, action_setting_reduced_motion)
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settings/timeline"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
	dy += 8
	
	// Timeline
	tab_control_switch()
	draw_switch("settings/timeline/auto_scroll", dx, dy, setting_timeline_autoscroll, action_setting_timeline_autoscroll)
	tab_next()
	
	tab_control_switch()
	draw_switch("settings/timeline/select_jump", dx, dy, setting_timeline_select_jump, action_setting_timeline_select_jump)
	tab_next()
	
	tab_control_switch()
	draw_switch("settings/timeline/frame_snap", dx, dy, setting_timeline_frame_snap, action_setting_timeline_frame_snap, "settings/timeline/frame_snap_tip")
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settings/tools"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
	dy += 8
	
	// Z is up
	tab_control_switch()
	draw_switch("settings/z_is_up", dx, dy, setting_z_is_up, action_setting_z_is_up)
	tab_next()
	
	// Separate tool modes
	tab_control_switch()
	draw_switch("settings/separate_tool_modes", dx, dy, setting_separate_tool_modes, action_setting_separate_tool_modes, "settings/separate_tool_modes_tip")
	tab_next()
	
	dy += label_height + 6
	draw_label(text_get("settings/viewport"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label)
	dy += 8
	
	// Quick mode shading
	tab_control_switch()
	draw_switch("settings/quick_mode_shading", dx, dy, setting_quick_mode_shading, action_setting_quick_mode_shading)
	tab_next()
	
	// Quick mode anti-aliasing
	tab_control_switch()
	draw_switch("settings/quick_mode_aa", dx, dy, setting_quick_mode_aa, action_setting_quick_mode_aa)
	tab_next()
	
	// Gizmos face camera
	tab_control_switch()
	draw_switch("settings/gizmos_face_camera", dx, dy, setting_gizmos_face_camera, action_setting_gizmos_face_camera)
	tab_next()
	
	// Fade gizmos
	tab_control_switch()
	draw_switch("settings/fade_gizmos", dx, dy, setting_fade_gizmos, action_setting_fade_gizmos)
	tab_next()
	
	// Lock mouse
	tab_control_switch()
	draw_switch("settings/camera_lock_mouse", dx, dy, setting_camera_lock_mouse, action_setting_camera_lock_mouse)
	tab_next()
	
	// Place new objects
	tab_control_switch()
	draw_switch("settings/place_new", dx, dy, setting_place_new, action_setting_place_new)
	tab_next()
}
