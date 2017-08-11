/// block_get_render_models(block, state, [ongenerate])
/// @arg block
/// @arg state
/// @arg [ongenerate]
/// @desc Returns an array of render models for the given block (null for no model, 0 to calculate on model generation).

var block, state, ongenerate;
block = argument[0]
state = argument[1]
if (argument_count > 2)
	ongenerate = argument[2]
else
	ongenerate = false

if (!is_undefined(block))
{
	ds_map_clear(mc_builder.vars)
	mc_builder.vars[?"normal"] = ""
	block_vars_string_to_map(state, mc_builder.vars)
	
	with (block)
	{
		// Requires render models
		if (require_models && !ongenerate)
			return 0
			
		// Get active file and properties
		var curfile, curtype, curbrightness;
		curfile = file
		curtype = type
		curbrightness = brightness
		
		// Check states
		if (states_map != null)
		{
			var curstate = ds_map_find_first(states_map);
			while (!is_undefined(curstate))
			{
				if (!is_undefined(mc_builder.vars[?curstate]))
				{
					// This state has a set value, check if it matches any of the possibilities
					with (states_map[?curstate])
					{
						for (var v = 0; v < value_amount; v++)
						{
							if (mc_builder.vars[?curstate] != value_name[v])
								continue
							
							// Match found, get the properties and stop checking further values in this state
							if (value_file[v] != null)
								curfile = value_file[v]
								
							if (value_type[v] != "")
								curtype = value_type[v]
								
							if (value_brightness[v] != null)
								curbrightness = value_brightness[v]
								
							break
						}
					}
				}
				curstate = ds_map_find_next(states_map, curstate)
			}
		}
		
		
		// Run a block specific script which returns either an array of models,
		// a custom generation script, 0 to continue or null to not render.
		if (curtype != "")
		{
			var script = asset_get_index("block_set_" + curtype);
			if (script > -1)
			{
				with (mc_builder)
				{
					var ret = script_execute(script);
					if (is_array(ret) || ret != 0)
						return ret
				}
			}
		}
		
		with (curfile)
		{
			// Variants
			if (variant_amount > 0)
			{
				for (var v = 0; v < variant_amount; v++)
				{
					with (variant[v])
					{
						if (model_amount = 0)
							break
				
						// Check if match
						if (is_undefined(vars[?"normal"]) || ds_map_size(vars) > 1)
							if (!block_vars_match(vars, mc_builder.vars))
								continue
				
						// Pick a random model from the list
						var m, rand = irandom(total_weight - 1);
						for (m = 0; m < model_amount; m++)
						{
							rand -= model[m].weight
							if (rand <= 0)
								break
						}
			
						// Return chosen model
						return array(model[m])
					}
				}
			}
			
			// Multipart
			else
			{
				var models, modelsamount;
				modelsamount = 0
				
				for (var c = 0; c < multipart_case_amount; c++)
				{
					with (multipart_case[c])
					{
						// Check conditions if available, otherwise this case always applies
						if (condition_amount > 0)
						{
							var match = false;
							for (var cd = 0; cd < condition_amount; cd++)
							{
								if (block_vars_match(condition[cd], mc_builder.vars))
								{
									match = true
									break
								}
							}
							if (!match)
								break
						}
						
						// Pick a random model from the list
						var m, rand = irandom(total_weight - 1);
						for (m = 0; m < model_amount; m++)
						{
							rand -= model[m].weight
							if (rand <= 0)
								break
						}
			
						// Add chosen model to the return
						models[modelsamount++] = model[m]
					}
				}
				
				if (modelsamount > 0)
					return models
			}
		}
	}
}

return null