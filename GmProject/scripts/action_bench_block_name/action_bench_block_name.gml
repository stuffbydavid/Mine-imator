/// action_bench_block_name(block)
/// @arg block
/// @desc Sets the block name of the workbench settings.

function action_bench_block_name(block)
{
	with (bench_settings)
	{
		var s = string_lower(block_list.search_tbx.text);
		
		if (block_name = block && s = "")
			return 0
		
		block_name = block
		block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
		
		// Modify states for better search
		if (s != "" && !string_contains(string_lower(minecraft_asset_get_name("block", mc_assets.block_name_map[?block].name)), s))
		{
			var b, state, val;
			b = mc_assets.block_name_map[?block]
			
			for (var i = 0; i < array_length(block_state); i += 2)
			{
				var state = block_state[i];
				var statelist = b.states_map[?state];
				
				for (var j = 0; j < statelist.value_amount; j++)
				{
					val = statelist.value_name[j]
					
					if (string_contains(string_lower(minecraft_asset_get_name("blockstatevalue", val)), s))
					{
						state_vars_set_value(block_state, state, val)
						break
					}
				}
			}
		}
		
		temp_update_block()
		
		preview.update = true
	}
}
