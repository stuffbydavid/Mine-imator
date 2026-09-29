/// @desc Sets the block name of the workbench settings.

function action_bench_block_name(name)
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
		list = bench_settings.block_list
	}
	
	search = string_lower(list.search_tbx.text)
	
	with (settings)
	{
		if (block_name = name && search = "")
			return 0
		
		block_name = name
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		
		// Modify states for better search
		if (search != "" && !string_contains(string_lower(minecraft_asset_get_name("block", mc_assets.block_name_map[?name].name)), search))
		{
			var block = mc_assets.block_name_map[?name];
			
			for (var i = 0; i < array_length(block_state); i += 2)
			{
				var state, statelist;
				state = block_state[i]
				statelist = block.states_map[?state]
				
				for (var j = 0; j < statelist.value_amount; j++)
				{
					var value = statelist.value_name[j];
					
					if (string_contains(string_lower(minecraft_asset_get_name("blockstatevalue", value)), search))
					{
						state_vars_set_value(block_state, state, value)
						break
					}
				}
			}
		}
		
		temp_update_block()
		
		if (preview != null)
			preview.update = true
	}
}
