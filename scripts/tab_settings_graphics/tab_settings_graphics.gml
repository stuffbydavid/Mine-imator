/// tab_settings_graphics()

// Bending
tab_control_checkbox()
draw_label(text_get("settingsbendstyle") + ":", dx, dy)
tab_next()
tab_control_checkbox()
draw_radiobutton("settingsbendstylerealistic", dx, dy, "realistic", (setting_bend_style = "realistic"), action_setting_bend_style)
draw_radiobutton("settingsbendstyleblocky", dx + floor(dw * 0.35), dy, "blocky", (setting_bend_style = "blocky"), action_setting_bend_style)
tab_next()
dy += 10

// Scenery
tab_control_checkbox()
draw_checkbox("settingsschematicremoveedges", dx, dy, setting_schematic_remove_edges, action_setting_schematic_remove_edges)
tab_next()
tab_control_checkbox()
draw_checkbox("settingsliquidanimation", dx, dy, setting_liquid_animation, action_setting_liquid_animation)
tab_next()
tab_control_checkbox()
draw_checkbox("settingsnoisygrasswater", dx, dy, setting_noisy_grass_water, action_setting_noisy_grass_water)
tab_next()
tab_control_checkbox()
draw_checkbox("settingsremovewaterloggedwater", dx, dy, setting_remove_waterlogged_water, action_setting_remove_waterlogged_water)
tab_next()
dy += 10

// Texture filtering
tab_control_checkbox()
draw_checkbox("settingstexturefiltering", dx, dy, setting_texture_filtering, action_setting_texture_filtering)
tab_next()

if (setting_texture_filtering)
{
	// Transparent block texture filtering
	tab_control_checkbox()
	draw_checkbox("settingstransparentblocktexturefiltering", dx, dy, setting_transparent_block_texture_filtering, action_setting_transparent_block_texture_filtering)
	tab_next()
	
	// Texture filtering level
	tab_control_meter()
	draw_meter("settingstexturefilteringlevel", dx, dy, dw, setting_texture_filtering_level, 48, 0, 5, 1, 1, tab.graphics.tbx_texture_filtering_level, action_setting_texture_filtering_level)
	tab_next()
}

// Block brightness
tab_control_meter()
draw_meter("settingsblockbrightness", dx, dy, dw, round(setting_block_brightness * 100), 48, 0, 100, 75, 0, tab.graphics.tbx_block_brightness, action_setting_block_brightness)
tab_next()

// Apply glow to bright blocks
tab_control_checkbox()
draw_checkbox("settingsblockglow", dx, dy, setting_block_glow, action_setting_block_glow)
tab_next()

// Foliage light bleeding
tab_control_checkbox()
draw_checkbox("settingslightbleeding", dx, dy, setting_light_bleeding, action_setting_light_bleeding)
tab_next()