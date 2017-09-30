/// block_set_double_plant()
/// @desc Returns an array with the upper and lower plant models.

var half = state_vars_get_value(vars, "half");
if (half = null || half = "upper")
	return 0
	
var models = array(null, null)
var variantval = state_vars_get_value(vars, "variant");

with (block_current.states_map[?"variant"])
{
	for (var val = 0; val < value_amount; val++)
	{
		if (value_name[val] != variantval)
			continue
	
		with (value_file[val])
		{
			for (var v = 0; v < variant_amount; v++)
			{
				with (variant[v])
				{
					if (model_amount = 0)
						break
				
					if (state_vars_get_value(vars, "half") = "lower")
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