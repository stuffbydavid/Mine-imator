/// tab_settings_program()

function tab_settings_program()
{
	var capwid = text_caption_width("settingsminecraftversion");
	
	// Minecraft assets version
	tab_control(24)
	draw_button_menu("settingsminecraftversion", e_menu.LIST, dx, dy, dw, 24, setting_minecraft_assets_version, setting_minecraft_assets_version, action_setting_minecraft_assets_version, false, null, null, "", c_white, c_white, capwid)
	tab_next()
	
	// Use x64 world importer
	tab_control_switch()
	draw_switch("settings64bitimport", dx, dy, setting_64bit_import, action_setting_64bit_import)
	tab_next()
	
	// FPS
	tab_control_togglebutton()
	togglebutton_add("settingsfps30", null, 30, room_speed = 30, action_setting_fps)
	togglebutton_add("settingsfps60", null, 60, room_speed = 60, action_setting_fps)
	draw_togglebutton("settingsfps", dx, dy, true, true)
	tab_next()
	
	// Backups
	tab_control_switch()
	draw_button_collapse("backup", collapse_map[?"backup"], action_setting_backup, setting_backup, "settingsbackup")
	tab_next()
	
	if (setting_backup && collapse_map[?"backup"])
	{
		tab_collapse_start()
		
		tab.program.tbx_backup_time.suffix = text_get("settingsbackuptimeminutes")
		
		tab_control_dragger()
		draw_dragger("settingsbackuptime", dx, dy, dragger_width, setting_backup_time, 0.1, 1, 120, 10, 1, tab.program.tbx_backup_time, action_setting_backup_time)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("settingsbackupamount", dx, dy, dragger_width, setting_backup_amount, 0.1, 1, 20, 3, 1, tab.program.tbx_backup_amount, action_setting_backup_amount)
		tab_next()
		
		tab_collapse_end()
	}
	
	#region Watermark
	
	tab_control_switch()
	if (draw_button_collapse("watermark", collapse_map[?"watermark"], null, true, "settingswatermark"))
	{
		if (trial_version)
		{
			collapse_map[?"watermark"] = false
			popup_show(popup_upgrade)
		}
	}
	tab_next()
	
	if (!trial_version && collapse_map[?"watermark"])
	{
		tab_collapse_start()
		
		// Watermark Image
		var fn = ((setting_watermark_filename = "") ? text_get("settingswatermarkdefault") : setting_watermark_filename);
		
		tab_control(24)
		draw_label_value(dx, dy, dw - 32, 24, text_get("settingswatermarkimage"), fn)
		tab_next()
		
		tab_control(24)
		
		if (draw_button_icon("settingswatermarkopen", dx, dy, 24, 24, false, icons.FOLDER))
			action_setting_watermark_open()
		
		if (draw_button_icon("settingswatermarkreset", dx + 32, dy, 24, 24, false, icons.RESET))
			action_setting_watermark_reset()
		
		tab_next()
		
		// X Position
		tab_control_menu()
		draw_button_menu("settingswatermarkpositionx", e_menu.LIST, dx, dy, dw, 24, setting_watermark_anchor_x, text_get("settingswatermark" + setting_watermark_anchor_x), action_setting_watermark_position_x)
		tab_next()
		
		// Y Position
		tab_control_menu()
		draw_button_menu("settingswatermarkpositiony", e_menu.LIST, dx, dy, dw, 24, setting_watermark_anchor_y, text_get("settingswatermark" + setting_watermark_anchor_y), action_setting_watermark_position_y)
		tab_next()
		
		// Scale
		tab_control_meter()
		draw_meter("settingswatermarkscale", dx, dy, dw, round(setting_watermark_scale * 100), 48, 0, 1000, 100, 1, tab.program.tbx_watermark_scale, action_setting_watermark_scale)
		tab_next()
		
		// Alpha
		tab_control_meter()
		draw_meter("settingswatermarkalpha", dx, dy, dw, round(setting_watermark_alpha * 100), 48, 0, 100, 100, 1, tab.program.tbx_watermark_alpha, action_setting_watermark_alpha)
		tab_next()
		
		// Preview
		draw_watermark_preview(dx, dy, dw)
		
		tab_collapse_end()
	}
	else
	{
		if (trial_version)
			draw_tooltip_label("settingswatermarkupgraderequired", icons.KEY_ALT, e_toast.INFO)
	}
	
	#endregion
	
	// Debug features
	tab_control_switch()
	draw_switch("settingsdebugfeatures", dx, dy, setting_debug_features, action_setting_debug_features, "", false, true)
	tab_next()
	
	// Spawn objects
	tab_control_switch()
	draw_switch("settingsspawnobjects", dx, dy, setting_spawn_objects, action_setting_spawn_objects)
	tab_next()
	
	// Spawn cameras
	tab_control_switch()
	draw_switch("settingsspawncameras", dx, dy, setting_spawn_cameras, action_setting_spawn_cameras)
	tab_next()
	
	// Unlimited values
	tab_control_switch()
	draw_switch("settingsunlimitedvalues", dx, dy, setting_unlimited_values, action_setting_unlimited_values)
	tab_next()
	
	// Remove edges on large scenery
	tab_control_switch()
	draw_switch("settingssceneryremoveedges", dx, dy, setting_scenery_remove_edges, action_setting_scenery_remove_edges)
	tab_next()
}
