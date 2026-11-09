/// @desc Returns the block/state IDs for a special block model, or null if unavailable.
/// @arg modelname
/// @arg modelstate

function block_get_from_timeline(modelname, modelstate)
{
	for (var b = 1; b < array_length(block_objs); b++)
	{
		var block = block_objs[b];
		if (block = null || !block.timeline || block.tl_model_name != modelname)
			continue

		if (!block.tl_has_model_state)
			return [ block.block_id, block_get_state_id(block, modelstate) ]

		for (var m = 0; m < max(1, block.tl_model_state_amount); m++)
		{
			var vars, stateid;
			vars = block.tl_model_state
			stateid = 0

			if (block.tl_model_state_amount > 0)
			{
				var state = block.tl_model_state[m];
				if (array_length(state.state_id) = 0)
					continue

				vars = state.value
				stateid = state.state_id_default
			}

			// Compare named values independently of their order
			if (array_length(vars) != array_length(modelstate))
				continue

			var matches = true;
			for (var s = 0; s < array_length(vars); s += 2)
			{
				if (state_vars_get_value(modelstate, vars[s]) != vars[s + 1])
				{
					matches = false
					break
				}
			}

			if (matches)
				return [ block.block_id, stateid ]
		}
	}

	return null
}
