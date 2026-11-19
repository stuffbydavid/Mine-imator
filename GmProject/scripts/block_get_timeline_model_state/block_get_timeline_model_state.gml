/// @desc Returns the special block timeline's model state.
/// @arg block
/// @arg stateid

function block_get_timeline_model_state(block, stateid)
{
	if (block.tl_model_name = "")
		return []

	// Copy the block state when no model-state mapping is defined
	if (!block.tl_has_model_state)
		return block_get_state_id_state_vars(block, stateid)

	if (block.tl_model_state_amount = 0)
		return array_copy_1d(block.tl_model_state)

	// Use the first matching model-state rule
	for (var i = 0; i < block.tl_model_state_amount; i++)
	{
		var rule = block.tl_model_state[i];
		if (array_contains(rule.state_id, stateid))
			return array_copy_1d(rule.value)
	}

	return []
}
