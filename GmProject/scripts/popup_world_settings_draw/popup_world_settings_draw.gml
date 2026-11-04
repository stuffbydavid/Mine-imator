function popup_world_settings_draw()
{
	dw = dw / 2 - 10
	
	// Unload far away regions
	tab_control_switch()
	draw_switch("world_settings/unload_regions", dx, dy, popup_world_settings.unload_regions, action_world_settings_unload_regions, "world_settings/unload_regions_tip")
	tab_next()
	
	// Filter settings
	draw_block_settings_filter()

	dy += 12

	// Confirm
	tab_control_button_label()
	if (draw_button_label("world_settings/confirm", content_x + content_width / 2, content_y + content_height - tab_control_h - 12, 100, null, e_button.PRIMARY, null, e_anchor.CENTER))
		popup_close()
	tab_next()
}
