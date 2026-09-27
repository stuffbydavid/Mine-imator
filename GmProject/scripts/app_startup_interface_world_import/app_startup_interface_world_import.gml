/// function app_startup_interface_world_import()
/// Initialize world import variables

function app_startup_interface_world_import()
{ 
	world_import_settings_popup = new_popup("worldsettings", popup_worldsettings_draw, 600, 532, true, false, false, true, world_import_apply_settings)
	world_import_surface = null
	world_import_add_tl = false
	world_import_temp = null
	
	world_import_settings_block_select = null
	world_import_settings_block_list = new_obj(obj_sortlist)
	world_import_settings_block_list.height_items = 10
	world_import_settings_block_list.can_deselect = true
	world_import_settings_block_list.script = action_world_import_settings_block_select
	
	sortlist_column_add(world_import_settings_block_list, "blockfilter", 0)
	for (var b = 0; b < ds_list_size(mc_assets.block_list); b++)
		if (ds_list_find_index(setting_world_import_filter_list, b) < 0) // Not filtered
			sortlist_add(world_import_settings_block_list, b)
		
	world_import_settings_filter_select = null
	world_import_settings_filter_list = new_obj(obj_sortlist)
	world_import_settings_filter_list.height_items = 10
	world_import_settings_filter_list.can_deselect = true
	world_import_settings_filter_list.script = action_world_import_settings_filter_select
	
	sortlist_column_add(world_import_settings_filter_list, "blockfilter", 0)
	for (var i = 0; i < ds_list_size(setting_world_import_filter_list); i++) // Add indices from filter list
		sortlist_add(world_import_settings_filter_list, setting_world_import_filter_list[|i])
	
	tbx_worldimport_gotoposition_x = new_textbox_ninteger()
	tbx_worldimport_gotoposition_z = new_textbox_ninteger()
	world_import_settings_gotoposition_x = 0
	world_import_settings_gotoposition_z = 0
	
	world_import_startup()
}