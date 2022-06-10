/// tab_settings_program()

function tab_settings_program()
{
	var capwid = text_caption_width("settingsminecraftversion");
	
	// Program mode
	tab_control_togglebutton()
	togglebutton_add("settingsmodesimple", null, false, !setting_advanced_mode, action_setting_program_mode)
	togglebutton_add("settingsmodeadvanced", null, true, setting_advanced_mode, action_setting_program_mode)
	draw_togglebutton("settingsmode", dx, dy, true, true)
	tab_next()
	
	draw_tooltip_label(setting_advanced_mode ? "settingsmodeadvancedtip" : "settingsmodesimpletip", icons.INFO, e_toast.INFO)
	
	// Minecraft assets version
	tab_control(24)
	draw_button_menu("settingsminecraftversion", e_menu.LIST, dx, dy, dw, 24, setting_minecraft_assets_version, setting_minecraft_assets_version, action_setting_minecraft_assets_version, false, null, null, "", c_white, c_white, capwid)
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
		draw_dragger("settingsbackuptime", dx, dy, dragger_width, setting_backup_time, 0.1, 1, 120, 3, 1, tab.program.tbx_backup_time, action_setting_backup_time)
		tab_next()
		
		tab_control_dragger()
		draw_dragger("settingsbackupamount", dx, dy, dragger_width, setting_backup_amount, 0.1, 1, 20, 5, 1, tab.program.tbx_backup_amount, action_setting_backup_amount)
		tab_next()
		
		tab_collapse_end()
	}
	
	// Spawn cameras
	tab_control_switch()
	draw_switch("settingsspawncameras", dx, dy, setting_spawn_cameras, action_setting_spawn_cameras)
	tab_next()
	
	// Unlimited values (Advanced mode only)
	if (setting_advanced_mode)
	{
		tab_control_switch()
		draw_switch("settingsunlimitedvalues", dx, dy, setting_unlimited_values, action_setting_unlimited_values)
		tab_next()
	}
	
	// Remove edges on large scenery
	tab_control_switch()
	draw_switch("settingssceneryremoveedges", dx, dy, setting_scenery_remove_edges, action_setting_scenery_remove_edges)
	tab_next()
}
