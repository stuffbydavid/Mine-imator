/// @desc Returns the timeline rotation point for a block state.
/// @arg block
/// @arg stateid

function block_get_timeline_rot_point(block, stateid)
{
	// Use the first matching state, otherwise the default value
	for (var i = 0; i < block.tl_rot_point_state_amount; i++)
	{
		var rotpointstate = block.tl_rot_point_state[i];
		if (array_contains(rotpointstate.state_id, stateid))
			return array_copy_1d(rotpointstate.value)
	}

	return array_copy_1d(block.tl_rot_point)
}
