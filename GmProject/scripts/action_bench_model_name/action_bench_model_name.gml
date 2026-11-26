function action_bench_model_name(name, state = null)
{
	var settings, picker, search;
	
	if (place_build)
	{
		settings = build_settings
		picker = build_tool.build_picker
	}
	else
	{
		settings = bench_settings
		switch (settings.type)
		{
			case e_temp_type.CHARACTER:		picker = settings.char_picker; break
			case e_temp_type.EQUIPMENT:		picker = settings.equipment_picker; break
			case e_temp_type.SPECIAL_BLOCK: picker = settings.special_block_picker; break
			case e_temp_type.MODEL_PART:	picker = settings.model_part_model_picker; break
		}
	}
	
	search = string_lower(picker.search_tbx.text)
	if (state = null)
		state = asset_picker_get_state(mc_assets.model_name_map[?name], search)
	
	asset_picker_state_map[?mc_assets.model_name_map[?name]] = array_copy_1d(state)
	
	with (settings)
	{
		if (model_name = name && array_equals(model_state, state))
			return 0
		
		model_name = name
		model_state = array_copy_1d(state)
		
		temp_update_model()
		
		if (type = e_temp_type.MODEL_PART)
			temp_update_model_part()
		
		temp_update_model_shape()
		
		if (preview != null)
		{
			with (preview)
			{
				preview_reset_view()
				update = true
			}
		}
	}
}
