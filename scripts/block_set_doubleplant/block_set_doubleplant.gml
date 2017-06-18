/// block_set_doubleplant()
/// @desc Returns an array with the upper and lower plant models.

if (is_undefined(vars[?"half"]) || vars[?"half"] = "upper")
	return 0
	
var block, models;
block = mc_version.block_map[?block_id_current];
models = 0

with (block.data_states[block_data_current])
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

return models