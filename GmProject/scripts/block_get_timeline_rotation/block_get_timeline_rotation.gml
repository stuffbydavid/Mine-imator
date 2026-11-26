/// @desc Returns the timeline rotation for a block state.
/// @arg block
/// @arg stateid

function block_get_timeline_rotation(block, stateid)
{
	// Use the first matching state, otherwise the default value
	for (var i = 0; i < block.tl_rotation_state_amount; i++)
	{
		var rotstate = block.tl_rotation_state[i];
		if (array_contains(rotstate.state_id, stateid))
			return array_copy_1d(rotstate.value)
	}

	return array_copy_1d(block.tl_rotation)
}
