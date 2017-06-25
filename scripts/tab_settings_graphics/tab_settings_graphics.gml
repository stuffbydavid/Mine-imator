/// tab_settings_graphics()

var capwid = text_caption_width("settingsbenddetail", "settingsbendscale")

// Bending
tab_control_checkbox()
draw_label(text_get("settingsbenddefault") + ":", dx, dy)
draw_radiobutton("settingsbenddefaultsharp", dx + floor(dw * 0.4), dy, 0, !setting_bend_round_default, action_setting_bend_round_default)
draw_radiobutton("settingsbenddefaultround", dx + floor(dw * 0.7), dy, 1, setting_bend_round_default, action_setting_bend_round_default)
tab_next()

tab_control_dragger()
draw_dragger("settingsbenddetail", dx, dy, dw, setting_bend_detail, 0.05, 1, no_limit, 3, 1, tab.graphics.tbx_bend_detail, action_setting_bend_detail)
tab_next()

tab_control_dragger()
draw_dragger("settingsbendscale", dx, dy, dw, setting_bend_scale, setting_bend_scale / 1000, 1, no_limit, 1.001, 0, tab.graphics.tbx_bend_scale, action_setting_bend_scale)
tab_next()
dy += 10

// Scenery
tab_control_checkbox()
draw_checkbox("settingsschematicremoveedges", dx, dy, setting_schematic_remove_edges, action_setting_schematic_remove_edges)
tab_next()

tab_control_checkbox()
draw_checkbox("settingsliquidanimation", dx, dy, setting_liquid_animation, action_setting_liquid_animation)
tab_next()

// Texture filtering
tab_control_checkbox()
draw_checkbox("settingstexturefiltering", dx, dy, setting_texture_filtering, action_setting_texture_filtering)
tab_next()

if (setting_texture_filtering)
{
	// Transparent texture filtering
	tab_control_checkbox()
	draw_checkbox("settingstransparenttexturefiltering", dx, dy, setting_transparent_texture_filtering, action_setting_transparent_texture_filtering)
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
