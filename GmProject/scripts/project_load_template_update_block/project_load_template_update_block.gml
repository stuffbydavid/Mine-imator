/// project_load_template_update_block()

function project_load_template_update_block()
{
	if (!is_undefined(mc_assets.block_name_map[?block_name]))
	{
		load_update_tree = true
				
		// Add new states
		if (array_length(block_state) != array_length(mc_assets.block_name_map[?block_name].default_state))
		{
			var statesprev = array_copy_1d(block_state);
			block_state = array_copy_1d(mc_assets.block_name_map[?block_name].default_state)
			state_vars_add(block_state, statesprev)
		}
		
		// Update legacy block state values
		if (legacy_block_state_values_map[?block_name] != undefined)
		{
			var legacyblockmap, statename;
			legacyblockmap = legacy_block_state_values_map[?block_name]
			
			for (var i = 0; i < array_length(block_state); i += 2)
			{
				statename = block_state[i]
				
				if (legacyblockmap[?statename] != undefined)
				{
					var statemap, statevalue;
					statemap = legacyblockmap[?statename]
					statevalue = block_state[i + 1]
					
					if (ds_map_valid(statemap[?statevalue])) // Replace multiple/different values
					{
						var valmap = statemap[?statevalue];
						
						// Look for values and update
						for (var j = 0; j < array_length(block_state); j += 2)
						{
							var state = block_state[j];
							
							if (valmap[?state] != undefined)
								block_state[j + 1] = valmap[?state]
						}
					}
					else // Replace single value
					{
						if (statemap[?statevalue] != undefined)
							block_state[i + 1] = statemap[?statevalue]
					}
				}
			}
		}
	}
}