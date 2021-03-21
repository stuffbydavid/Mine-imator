/// tab_settings_graphics()

// Bending
tab_control_togglebutton()
togglebutton_add("settingsbendstylerealistic", null, "realistic", setting_bend_style = "realistic", action_setting_bend_style)
togglebutton_add("settingsbendstyleblocky", null, "blocky", setting_bend_style = "blocky", action_setting_bend_style)
draw_togglebutton("settingsbendstyle", dx, dy)
tab_next()

// Scenery
tab_control_switch()
draw_switch("settingssceneryremoveedges", dx, dy, setting_scenery_remove_edges, action_setting_scenery_remove_edges)
tab_next()

tab_control_switch()
draw_switch("settingsliquidanimation", dx, dy, setting_liquid_animation, action_setting_liquid_animation)
tab_next()

tab_control_switch()
draw_switch("settingsnoisygrasswater", dx, dy, setting_noisy_grass_water, action_setting_noisy_grass_water)
tab_next()

tab_control_switch()
draw_switch("settingsremovewaterloggedwater", dx, dy, setting_remove_waterlogged_water, action_setting_remove_waterlogged_water)
tab_next()

// Texture filtering
tab_control_switch()
draw_button_collapse("texfilter", collapse_map[?"texfilter"], null, !setting_texture_filtering)
draw_switch("settingstexturefiltering", dx, dy, setting_texture_filtering, action_setting_texture_filtering)
tab_next()

if (setting_texture_filtering && collapse_map[?"texfilter"])
{
	tab_collapse_start()
	
	// Transparent block texture filtering
	tab_control_switch()
	draw_switch("settingstransparentblocktexturefiltering", dx, dy, setting_transparent_block_texture_filtering, action_setting_transparent_block_texture_filtering)
	tab_next()
	
	// Texture filtering level
	tab_control_meter()
	draw_meter("settingstexturefilteringlevel", dx, dy, dw, setting_texture_filtering_level, 48, 0, 5, 1, 1, tab.graphics.tbx_texture_filtering_level, action_setting_texture_filtering_level)
	tab_next()
	
	tab_collapse_end()
}

// Block brightness
tab_control_meter()
draw_meter("settingsblockbrightness", dx, dy, dw, round(setting_block_brightness * 100), 48, 0, 100, 75, 1, tab.graphics.tbx_block_brightness, action_setting_block_brightness)
tab_next()

// Apply glow to bright blocks
tab_control_switch()
draw_switch("settingsblockglow", dx, dy, setting_block_glow, action_setting_block_glow)
tab_next()

// Glow threshold
if (setting_block_glow)
{
	tab_control_meter()
	draw_meter("settingsblockglowthreshold", dx, dy, dw, round(setting_block_glow_threshold * 100), 48, 0, 100, 75, 1, tab.graphics.tbx_block_glow_threshold, action_setting_block_glow_threshold)
	tab_next()
}

// Foliage light bleeding
tab_control_switch()
draw_switch("settingslightbleeding", dx, dy, setting_light_bleeding, action_setting_light_bleeding)
tab_next()