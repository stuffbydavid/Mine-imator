/// tab_settings_program()

var capwid = text_caption_width("settingsminecraftversion");

// Minecraft assets version
tab_control(24)
draw_button_menu("settingsminecraftversion", e_menu.LIST, dx, dy, dw, 24, setting_minecraft_assets_version, setting_minecraft_assets_version, action_setting_minecraft_assets_version, false, null, null, "", c_white, c_white, capwid)
tab_next()

// FPS
tab_control_togglebutton()
togglebutton_add("settingsfps30", null, 30, room_speed = 30, action_setting_fps)
togglebutton_add("settingsfps60", null, 60, room_speed = 60, action_setting_fps)
draw_togglebutton("settingsfps", dx, dy, true, true)
tab_next()

// Backups
tab_control_switch()
draw_button_collapse("backup", collapse_map[?"backup"], null, !setting_backup)
draw_switch("settingsbackup", dx, dy, setting_backup, action_setting_backup)
tab_next()

if (setting_backup && collapse_map[?"backup"])
{
	tab_collapse_start()
	
	tab.program.tbx_backup_time.suffix = " " + text_get("settingsbackuptimeminutes")
	
	tab_control_dragger()
	draw_dragger("settingsbackuptime", dx, dy, dragger_width, setting_backup_time, 0.1, 1, 120, 10, 1, tab.program.tbx_backup_time, action_setting_backup_time)
	tab_next()
	
	tab_control_dragger()
	draw_dragger("settingsbackupamount", dx, dy, dragger_width, setting_backup_amount, 0.1, 1, 20, 3, 1, tab.program.tbx_backup_amount, action_setting_backup_amount)
	tab_next()
	
	tab_collapse_end()
}

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
