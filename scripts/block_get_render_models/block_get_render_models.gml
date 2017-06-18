/// builder_get_render_models(id, data, [ongenerate])
/// @arg id
/// @arg data
/// @arg [ongenerate]
/// @desc Returns an array of render models for the given block (null for no model, 0 to calculate on model generation).

var bid, bdata, ongenerate;
bid = argument[0]
bdata = argument[1]
if (argument_count > 2)
	ongenerate = argument[2]
else
	ongenerate = false

if (!is_undefined(mc_version.block_map[?bid]))
{
	ds_map_clear(mc_builder.vars)
	mc_builder.vars[?"normal"] = ""
	
	with (mc_version.block_map[?bid])
	{
		var datavars = data_vars[bdata];
		
		if (datavars != null)
		{
			// Requires render models
			if (!is_undefined(datavars[?"requiremodels"]) && datavars[?"requiremodels"] = "true" && !ongenerate)
				return 0
				
			// Add builder variables
			ds_map_merge(mc_builder.vars, datavars)
		}
		
		// Run a block specific script which returns either an array of models,
		// a custom generation script, 0 to continue or null to not render.
		if (data_type[bdata] != "")
		{
			var script = asset_get_index("block_set_" + data_type[bdata]);
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
		
		with (data_states[bdata])
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
							if (!block_var_match(vars, mc_builder.vars))
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
								if (block_var_match(condition[cd], mc_builder.vars))
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