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

		if (block.tl_model_state_amount = 0)
		{
			if (array_equals(block.tl_model_state, modelstate))
				return [ block.block_id, 0 ]
			continue
		}

		for (var m = 0; m < block.tl_model_state_amount; m++)
		{
			var state = block.tl_model_state[m];
			if (array_equals(state.value, modelstate) && array_length(state.state_id) > 0)
				return [ block.block_id, state.state_id[0] ]
		}
	}

	return null
}
