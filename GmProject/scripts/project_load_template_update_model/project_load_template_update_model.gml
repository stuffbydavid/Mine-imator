function project_load_template_update_model()
{
	if (!is_undefined(mc_assets.model_name_map[?model_name]) && mc_assets.model_name_map[?model_name].version > model_version)
	{
		load_update_tree = true
				
		// Add new states
		if (array_length(model_state) != array_length(mc_assets.model_name_map[?model_name].default_state))
		{
			var statesprev = array_copy_1d(model_state);
			model_state = array_copy_1d(mc_assets.model_name_map[?model_name].default_state)
			state_vars_add(model_state, statesprev)
		}
		
		// Update legacy model state values
		if (!is_undefined(legacy_model_state_values_map[?model_name]))
		{
			var legacymodelmap, statename;
			legacymodelmap = legacy_model_state_values_map[?model_name]
			
			for (var i = 0; i < array_length(model_state); i += 2)
			{
				statename = model_state[i]
				
				if (!is_undefined(legacymodelmap[?statename]))
				{
					var statemap, statevalue;
					statemap = legacymodelmap[?statename]
					statevalue = model_state[i + 1]
					
					if (ds_map_valid(statemap[?statevalue])) // Replace multiple/different values
					{
						var valmap = statemap[?statevalue];
						
						// Look for values and update
						for (var j = 0; j < array_length(model_state); j += 2)
						{
							var state = model_state[j];
							
							if (!is_undefined(valmap[?state]))
								model_state[j + 1] = valmap[?state]
						}
					}
					else // Replace single value
					{
						if (!is_undefined(statemap[?statevalue]))
							model_state[i + 1] = statemap[?statevalue]
					}
				}
			}
		}
	}
}
