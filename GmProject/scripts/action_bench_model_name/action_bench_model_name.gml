/// action_bench_model_name(name)
/// @arg name

function action_bench_model_name(name)
{
	with (bench_settings)
	{
		var s;
		
		if (type = e_temp_type.CHARACTER)
			s = string_lower(char_list.search_tbx.text)
		else if (type = e_temp_type.SPECIAL_BLOCK)
			s = string_lower(special_block_list.search_tbx.text)
		else if (type = e_temp_type.BODYPART)
			s = string_lower(bodypart_model_list.search_tbx.text)
		
		if (model_name = name && s = "")
			return 0
		
		model_name = name
		model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
		
		// Modify states for better search
		if (s != "" && !string_contains(string_lower(minecraft_asset_get_name("model", model_name)), s))
		{
			var m, state, val;
			m = mc_assets.model_name_map[?name]
			
			for (var i = 0; i < array_length(model_state); i += 2)
			{
				var state = model_state[i];
				var statelist = m.states_map[?state];
				
				for (var j = 0; j < statelist.value_amount; j++)
				{
					val = statelist.value_name[j]
					
					if (string_contains(string_lower(minecraft_asset_get_name("modelstatevalue", val)), s))
					{
						state_vars_set_value(model_state, state, val)
						break
					}
				}
			}
		}
		
		temp_update_model()
		
		if (type = e_temp_type.BODYPART)
			temp_update_model_part()
		
		temp_update_model_shape()
		model_shape_update_color()
		
		if (pattern_type != "")
			array_add(pattern_update, id)
		
		temp_update_armor(id)
		
		with (preview)
		{
			preview_reset_view()
			update = true
		}
	}
}
