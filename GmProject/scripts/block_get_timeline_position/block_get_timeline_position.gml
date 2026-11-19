/// @desc Returns the local builder-space timeline position including state offsets.
/// @arg block
/// @arg stateid

function block_get_timeline_position(block, stateid)
{
	var pos = block.tl_position;

	// Use the first matching state, otherwise the default value
	for (var i = 0; i < block.tl_position_state_amount; i++)
	{
		var posstate = block.tl_position_state[i];
		if (array_contains(posstate.state_id, stateid))
		{
			pos = posstate.value
			break
		}
	}

	// Apply any state-dependent offset to the timeline anchor
	var offset = block.tl_offset;
	for (var i = 0; i < block.tl_offset_state_amount; i++)
	{
		var offsetstate = block.tl_offset_state[i];
		if (array_contains(offsetstate.state_id, stateid))
		{
			offset = offsetstate.value
			break
		}
	}

	return vec3_add(pos, offset)
}
