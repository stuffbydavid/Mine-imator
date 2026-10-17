function popup_worldsettings_draw()
{
	content_mouseon = true
	dw = dw/2
	
	// Unload far away regions
	tab_control_switch()
	draw_switch("world_settings/unload_regions", dx, dy, setting_world_import_unload_regions, action_world_import_settings_unload_regions, "world_settings/unload_regions_tip")
	tab_next()
	
	// Filter settings
	tab_control_switch()
	draw_switch("world_settings/filter_enabled", dx, dy, setting_world_import_filter_enabled, action_world_import_settings_filter_enabled)
	tab_next()
	
	if (setting_world_import_filter_enabled)
	{
		tab_control_togglebutton()
		togglebutton_add("world_settings/filter_remove", null, 0, setting_world_import_filter_mode = 0, action_world_import_settings_filter_mode)
		togglebutton_add("world_settings/filter_keep", null, 1, setting_world_import_filter_mode = 1, action_world_import_settings_filter_mode)
		draw_togglebutton("world_settings/filter_mode", dx, dy)
		tab_next()
		
		var listdw = content_width - 24;
		
		dy += 8
		
		tab_control_sortlist(world_import_settings_block_list)
		sortlist_draw(world_import_settings_block_list, dx, dy, listdw / 2 - 20, tab_control_h, world_import_settings_block_select, false, text_get("world_settings/filter_blocks"))
		sortlist_draw(world_import_settings_filter_list, dx + listdw / 2 + 20, dy, listdw / 2 - 20, tab_control_h, world_import_settings_filter_select, false, text_get("world_settings/filter_filtered"))
		
		if (draw_button_icon("world_settings/filterright", dx + listdw / 2 - 12, dy + (tab_control_h/2) - 16, 24, 24, false, icons.CHEVRON_RIGHT_TINY, null, world_import_settings_block_select = null))
		{
			sortlist_add(world_import_settings_filter_list, world_import_settings_block_select)
			sortlist_remove(world_import_settings_block_list, world_import_settings_block_select)
			sortlist_update(world_import_settings_filter_list)
			sortlist_update(world_import_settings_block_list)
			
			ds_list_add(setting_world_import_filter_list, world_import_settings_block_select)
			
			world_import_settings_block_select = null
		}
		
		if (draw_button_icon("world_settings/filterleft", dx + listdw / 2 - 12, dy + (tab_control_h/2) + 16, 24, 24, false, icons.CHEVRON_LEFT_TINY, null, world_import_settings_filter_select = null))
		{
			var blocklist, index;
			blocklist = world_import_settings_block_list.list
			
			for (index = 0; index < ds_list_size(blocklist); index++)
				if (blocklist[|index] > world_import_settings_filter_select)
					break
			
			sortlist_add(world_import_settings_block_list, world_import_settings_filter_select, index)
			sortlist_remove(world_import_settings_filter_list, world_import_settings_filter_select)
			sortlist_update(world_import_settings_block_list)
			sortlist_update(world_import_settings_filter_list)
			
			ds_list_delete_value(setting_world_import_filter_list, world_import_settings_filter_select)
			
			world_import_settings_filter_select = null
		}
		
		tab_next()
		
		dw = content_width - 24
		dy += 8
		draw_tooltip_label("world_settings/filter_help", icons.INFO, e_toast.INFO)
	}
}
