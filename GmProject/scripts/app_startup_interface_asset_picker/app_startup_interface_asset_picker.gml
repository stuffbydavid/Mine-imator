function app_startup_interface_asset_picker()
{
	globalvar asset_picker_preview, asset_picker_state_map;
	asset_picker_preview = new_obj(obj_preview)
	
	with (asset_picker_preview)
	{
		temp_event_create()

		select = id
		type = e_temp_type.BLOCK
		block_randomize = false
	}
	
	asset_picker_state_map = ds_int_map_create()

	// State settings
	state_settings_elements = []
	state_settings_height = 0
	state_settings_capwid = 0
	state_settings_asset = null
	state_settings_states = []
}
