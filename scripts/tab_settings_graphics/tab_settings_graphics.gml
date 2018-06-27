/// tab_settings_graphics()

// Texture filtering
tab_control_checkbox()
draw_checkbox("settingsbendpinch", dx, dy, setting_bend_pinch, action_setting_bend_pinch)
tab_next()

// Scenery
tab_control_checkbox()
draw_checkbox("settingsschematicremoveedges", dx, dy, setting_schematic_remove_edges, action_setting_schematic_remove_edges)
tab_next()
tab_control_checkbox()
draw_checkbox("settingsliquidanimation", dx, dy, setting_liquid_animation, action_setting_liquid_animation)
tab_next()
dy += 10

// Texture filtering
tab_control_checkbox()
draw_checkbox("settingstexturefiltering", dx, dy, setting_texture_filtering, action_setting_texture_filtering)
tab_next()

if (setting_texture_filtering)
{
	// Texture filtering level
	tab_control_meter()
	draw_meter("settingstexturefilteringlevel", dx, dy, dw, setting_texture_filtering_level, 48, 0, 5, 1, 1, tab.graphics.tbx_texture_filtering_level, action_setting_texture_filtering_level)
	tab_next()
}

// Block brightness
tab_control_meter()
draw_meter("settingsblockbrightness", dx, dy, dw, round(setting_block_brightness * 100), 48, 0, 100, 75, 0, tab.graphics.tbx_block_brightness, action_setting_block_brightness)
tab_next()