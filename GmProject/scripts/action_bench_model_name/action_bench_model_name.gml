/// action_bench_model_name(name)
/// @arg name

function action_bench_model_name(name)
{
	var settings, list, search;
	if (place_build)
	{
		settings = build_settings
		list = build_tool.build_list
	}
	else
	{
		settings = bench_settings
		switch (settings.type)
		{
			case e_temp_type.CHARACTER:
				list = settings.char_list
				break
			case e_temp_type.EQUIPMENT:
				list = settings.equipment_list
				break
			case e_temp_type.SPECIAL_BLOCK:
				list = settings.special_block_list
				break
			case e_temp_type.MODEL_PART:
				list = settings.special_block_list
				break
		}
	}
	
	search = string_lower(list.search_tbx.text)
	
	with (settings)
	{
		if (model_name = name && search = "")
			return 0
		
		model_name = name
		model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		
		// Modify states for better search
		if (search != "" && !string_contains(string_lower(minecraft_asset_get_name("model", model_name)), search))
		{
			var m, val;
			m = mc_assets.model_name_map[?name]
			
			for (var i = 0; i < array_length(model_state); i += 2)
			{
				var state = model_state[i];
				var statelist = m.states_map[?state];
				
				for (var j = 0; j < statelist.value_amount; j++)
				{
					val = statelist.value_name[j]
					
					if (string_contains(string_lower(minecraft_asset_get_name("modelstatevalue", val)), search))
					{
						state_vars_set_value(model_state, state, val)
						break
					}
				}
			}
		}
		
		temp_update_model()
		
		if (type = e_temp_type.MODEL_PART)
			temp_update_model_part()
		
		temp_update_model_shape()
		model_shape_update_color()
		
		if (pattern_type != "")
			array_add(pattern_update, id)
		
		temp_update_armor(id)
		
		if (preview != null)
			with (preview)
			{
				preview_reset_view()
				update = true
			}
	}
}
