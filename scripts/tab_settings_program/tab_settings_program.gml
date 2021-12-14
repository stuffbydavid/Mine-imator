/// tab_settings_program()

// Minecraft assets version
tab_control(24)
draw_button_menu("settingsminecraftversion", e_menu.LIST, dx, dy, dw, 24, setting_minecraft_assets_version, setting_minecraft_assets_version, action_setting_minecraft_assets_version)
tab_next()
dy += 10

// FPS
tab_control_checkbox()
draw_label(text_get("settingsfps") + ":", dx, dy)
draw_radiobutton("settingsfps30", dx + floor(dw * 0.15), dy, 30, (room_speed = 30), action_setting_fps)
draw_radiobutton("settingsfps60", dx + floor(dw * 0.35), dy, 60, (room_speed = 60), action_setting_fps)
tab_next()
dy += 10

// Backups
tab_control_checkbox()
draw_checkbox("settingsbackup", dx, dy, setting_backup, action_setting_backup)
tab_next()

if (setting_backup)
{
	var capwid = text_caption_width("settingsbackuptime", "settingsbackupamount");
	tab.program.tbx_backup_time.suffix = " " + text_get("settingsbackuptimeminutes")
	tab_control_dragger()
	draw_dragger("settingsbackuptime", dx, dy, dw, setting_backup_time, 0.1, 1, 120, 10, 1, tab.program.tbx_backup_time, action_setting_backup_time)
	tab_next()
	tab_control_dragger()
	draw_dragger("settingsbackupamount", dx, dy, dw, setting_backup_amount, 0.1, 1, 20, 3, 1, tab.program.tbx_backup_amount, action_setting_backup_amount)
	tab_next()
}
dy += 10

// Spawn objects
tab_control_checkbox()
draw_checkbox("settingsspawnobjects", dx, dy, setting_spawn_objects, action_setting_spawn_objects)
tab_next()

// Spawn cameras
tab_control_checkbox()
draw_checkbox("settingsspawncameras", dx, dy, setting_spawn_cameras, action_setting_spawn_cameras)
tab_next()

// Unlimited values
tab_control_checkbox()
draw_checkbox("settingsunlimitedvalues", dx, dy, setting_unlimited_values, action_setting_unlimited_values)
tab_next()

// x64 world importer
tab_control_checkbox()
draw_checkbox("settings64bitimport", dx, dy, setting_64bit_import, action_setting_64bit_import)
tab_next()
