function action_world_settings_confirm()
{
	var popup = popup_world_settings;
	setting_world_unload_regions = popup.unload_regions
	setting_world_filter_enabled = popup.filter_enabled
	setting_world_filter_mode = popup.filter_mode

	ds_list_clear(setting_world_filter_list)
	for (var i = 0; i < array_length(popup.filter_array); i++)
		ds_list_add(setting_world_filter_list, popup.filter_array[i])

	world_import_apply_settings()
}
