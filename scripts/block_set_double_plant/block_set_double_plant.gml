/// block_set_double_plant()
/// @desc Returns an array with the upper and lower plant models.

if (is_undefined(vars[?"half"]) || vars[?"half"] = "upper")
	return 0
	
var models = 0;

with (block_current.states_map[?"variant"])
{
	for (var val = 0; val < value_amount; val++)
	{
		if (value_name[val] != mc_builder.vars[?"variant"])
			continue
	
		with (value_file[val])
		{
			for (var v = 0; v < variant_amount; v++)
			{
				with (variant[v])
				{
					if (model_amount = 0)
						break
				
					if (vars[?"half"] = "lower")
						models[0] = model[0]
					else
					{
						model[0].offset[Z] = block_size
						models[1] = model[0]
					}
				}
			}
		}
	}
}

return models