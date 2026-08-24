/// tab_settings_program()

function tab_settings_program()
{
	// Program mode
	tab_control_togglebutton()
	togglebutton_add("settingsmodesimple", null, false, !setting_advanced_mode, action_setting_program_mode)
	togglebutton_add("settingsmodeadvanced", null, true, setting_advanced_mode, action_setting_program_mode)
	draw_togglebutton("settingsmode", dx, dy, true, true)
	tab_next()
	
	draw_tooltip_label(setting_advanced_mode ? "settingsmodeadvancedtip" : "settingsmodesimpletip", icons.INFO, e_toast.INFO)
	
	// Minecraft assets version
	tab_control_menu()
	draw_button_menu("settingsminecraftversion", e_menu.LIST, dx, dy, dw, 24, setting_minecraft_assets_version, setting_minecraft_assets_version, action_setting_minecraft_assets_version, false, null, null, "", c_white, c_white)
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
	
	// Custom watermark
	tab_control_switch()
	draw_button_collapse("watermark", collapse_map[?"watermark"], action_setting_watermark_custom, setting_watermark_custom, "settingswatermark")
	tab_next()
	
	if (setting_watermark_custom && collapse_map[?"watermark"])
	{
		tab_collapse_start()
		
		// Image location
		var directory = "../" + directory_name(setting_watermark_fn) + filename_name(setting_watermark_fn);
		
		if (setting_watermark_fn = "")
			directory = text_get("settingswatermarknone")
		
		tab_control(40)
		draw_label_value(dx, dy, dw - 56, 40, text_get("settingswatermarkimagelocation"), directory, true)
		if (draw_button_icon("settingswatermarkimport", dx + dw - (24 + 4 + 24), dy + 8, 24, 24, false, icons.ASSET_IMPORT, null, false, "tooltipimportwatermarkimage"))
			action_setting_watermark_import()
		if (draw_button_icon("settingswatermarkreset", dx + dw - 24, dy + 8, 24, 24, false, icons.RESET, null, setting_watermark_fn = "", "tooltipresetwatermarkimage"))
			action_setting_watermark_reset()
		tab_next()
		
		// Alignment
		dy += label_height + 6
		draw_label(text_get("settingswatermarkalignment"), dx, dy, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary, font_label) 
		dy += 8
		
		var dwold, dxold;
		dwold = dw
		dxold = dx
		
		dw = floor(dw/2 - 4)
		
		// Horizontal
		tab_control_togglebutton()
		togglebutton_add("settingswatermarkleft", icons.ALIGN_LEFT, "left", setting_watermark_halign = "left", action_setting_watermark_halign)
		togglebutton_add("settingswatermarkcenter", icons.ALIGN_CENTER, "center", setting_watermark_halign = "center", action_setting_watermark_halign)
		togglebutton_add("settingswatermarkright", icons.ALIGN_RIGHT, "right", setting_watermark_halign = "right", action_setting_watermark_halign)
		draw_togglebutton("settingswatermarkhalign", dx, dy, false)
		
		dx += (dw + 8)
		
		// Vertical
		togglebutton_add("settingswatermarktop", icons.ALIGN_TOP, "top", setting_watermark_valign = "top", action_setting_watermark_valign)
		togglebutton_add("settingswatermarkcenter", icons.ALIGN_MIDDLE, "center", setting_watermark_valign = "center", action_setting_watermark_valign)
		togglebutton_add("settingswatermarkbottom", icons.ALIGN_BOTTOM, "bottom", setting_watermark_valign = "bottom", action_setting_watermark_valign)
		draw_togglebutton("settingswatermarkvalign", dx, dy, false)
		tab_next()
		
		dx = dxold
		dw = dwold
		
		// Padding
		tab_control_meter()
		draw_meter("settingswatermarkpadding", dx, dy, dw, round(setting_watermark_padding * 100), 0, 100, 0, 1, tab.program.tbx_watermark_padding, action_setting_watermark_padding)
		tab_next()
		
		// Scale
		tab_control_meter()
		draw_meter("settingswatermarkscale", dx, dy, dw, round(setting_watermark_scale * 100), 0, 100, 33, 1, tab.program.tbx_watermark_scale, action_setting_watermark_scale)
		tab_next()
		
		// Opacity
		tab_control_meter()
		draw_meter("settingswatermarkopacity", dx, dy, dw, round(setting_watermark_opacity * 100), 0, 100, 100, 1, tab.program.tbx_watermark_opacity, action_setting_watermark_opacity)
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
