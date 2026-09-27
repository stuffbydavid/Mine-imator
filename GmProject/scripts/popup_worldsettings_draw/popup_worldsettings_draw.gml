/// popup_worldsettings_draw()

function popup_worldsettings_draw()
{
	content_mouseon = true
	dw = dw/2
	
	// Unload far away regions
	tab_control_switch()
	draw_switch("worldsettingsunloadregions", dx, dy, setting_world_import_unload_regions, action_world_import_settings_unload_regions, "worldsettingsunloadregionstip")
	tab_next()
	
	// Filter settings
	tab_control_switch()
	draw_switch("worldsettingsfilterenabled", dx, dy, setting_world_import_filter_enabled, action_world_import_settings_filter_enabled)
	tab_next()
	
	if (setting_world_import_filter_enabled)
	{
		tab_control_togglebutton()
		togglebutton_add("worldsettingsfilterremove", null, 0, setting_world_import_filter_mode = 0, action_world_import_settings_filter_mode)
		togglebutton_add("worldsettingsfilterkeep", null, 1, setting_world_import_filter_mode = 1, action_world_import_settings_filter_mode)
		draw_togglebutton("worldsettingsfiltermode", dx, dy)
		tab_next()
		
		var listdw = content_width - 24;
		
		dy += 8
		
		tab_control_sortlist(world_import_settings_block_list)
		sortlist_draw(world_import_settings_block_list, dx, dy, listdw / 2 - 20, tab_control_h, world_import_settings_block_select, false, text_get("worldsettingsfilterblocks"))
		sortlist_draw(world_import_settings_filter_list, dx + listdw / 2 + 20, dy, listdw / 2 - 20, tab_control_h, world_import_settings_filter_select, false, text_get("worldsettingsfilterfiltered"))
		
		if (draw_button_icon("worldsettingsfilterright", dx + listdw / 2 - 12, dy + (tab_control_h/2) - 16, 24, 24, false, icons.CHEVRON_RIGHT_TINY, null, world_import_settings_block_select = null))
		{
			sortlist_add(world_import_settings_filter_list, world_import_settings_block_select)
			sortlist_remove(world_import_settings_block_list, world_import_settings_block_select)
			sortlist_update(world_import_settings_filter_list)
			sortlist_update(world_import_settings_block_list)
			ds_list_add(setting_world_import_filter_list, world_import_settings_block_select)
			world_import_settings_block_select = null
		}
		
		if (draw_button_icon("worldsettingsfilterleft", dx + listdw / 2 - 12, dy + (tab_control_h/2) + 16, 24, 24, false, icons.CHEVRON_LEFT_TINY, null, world_import_settings_filter_select = null))
		{
			var blocklist = world_import_settings_block_list.list;
			var index;
			for (index = 0; index < ds_list_size(blocklist); index++)
				if (blocklist[|index] > world_import_settings_filter_select)
					break;
			
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
		draw_tooltip_label("worldsettingsfilterhelp", icons.INFO, e_toast.INFO)
	}
}