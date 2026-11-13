/// @desc Returns the updated block name and state from legacy mapping.

function block_get_name_state(blockname, blockstate)
{
	// Update names missing from the selected assets
	if (is_undefined(mc_assets.block_name_map[?blockname]))
	{
		var legacyname = legacy_block_names_map[?blockname];
		if (is_string(legacyname))
			blockname = legacyname
		else if (ds_map_valid(legacyname))
		{
			blockname = legacyname[?"name"]
			if (is_string(legacyname[?"state"]))
			{
				var statesprev = blockstate;
				blockstate = string_get_state_vars(legacyname[?"state"])
				state_vars_add(blockstate, statesprev)
			}
		}
	}

	// Update legacy state names
	if (!is_undefined(legacy_block_states_map[?blockname]))
	{
		var legacyblockmap = legacy_block_states_map[?blockname];
		for (var i = 0; i < array_length(blockstate); i += 2)
		{
			var statename = blockstate[i];
			if (!is_undefined(legacyblockmap[?statename]))
				blockstate[i] = legacyblockmap[?statename]
		}
	}

	if (!is_undefined(mc_assets.block_name_map[?blockname]))
	{
		// Add new states
		if (array_length(blockstate) != array_length(mc_assets.block_name_map[?blockname].default_state))
		{
			var statesprev = array_copy_1d(blockstate);
			blockstate = array_copy_1d(mc_assets.block_name_map[?blockname].default_state)
			state_vars_add(blockstate, statesprev)
		}
		
		// Update legacy block state values
		if (!is_undefined(legacy_block_state_values_map[?blockname]))
		{
			var legacyblockmap, statename;
			legacyblockmap = legacy_block_state_values_map[?blockname]
			
			for (var i = 0; i < array_length(blockstate); i += 2)
			{
				statename = blockstate[i]
				
				if (!is_undefined(legacyblockmap[?statename]))
				{
					var statemap, statevalue;
					statemap = legacyblockmap[?statename]
					statevalue = blockstate[i + 1]
					
					if (ds_map_valid(statemap[?statevalue])) // Replace multiple/different values
					{
						var valmap = statemap[?statevalue];
						
						// Look for values and update
						for (var j = 0; j < array_length(blockstate); j += 2)
						{
							var state = blockstate[j];
							
							if (!is_undefined(valmap[?state]))
								blockstate[j + 1] = valmap[?state]
						}
					}
					else // Replace single value
					{
						if (!is_undefined(statemap[?statevalue]))
							blockstate[i + 1] = statemap[?statevalue]
					}
				}
			}
		}
	}

	return [ blockname, blockstate ]
}
