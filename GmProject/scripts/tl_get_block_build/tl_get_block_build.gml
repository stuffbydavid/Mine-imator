/// @desc Returns current block data without retaining stale model or variant selections.

function tl_get_block_build()
{
	if (type != e_tl_type.BLOCK && type != e_tl_type.SPECIAL_BLOCK)
		return null

	// Reuse the original placement state when it still matches the current model
	if (block_build_name != "")
	{
		var block = mc_assets.block_name_map[?block_build_name];
		if (!is_undefined(block))
		{
			var stateid, valid;
			stateid = block_get_state_id(block, block_build_state)
			valid = false
			
			if (type = e_tl_type.BLOCK && temp.block_name = block.name)
			{
				// Compare against the render state with timeline transforms removed
				var renderstate = stateid;
				if (block.timeline)
					renderstate = block_get_state_id(block, block_get_timeline_render_state(block, stateid))
				
				valid = (block_get_state_id(block, temp.block_state) = renderstate)
				
				// Standalone beds render from the head even when placed from the foot
				if (block.type = "bed")
					valid = (block_get_state_id(block, temp.block_state) = block_set_state_id_value(block, stateid, "part", "head"))
			}
			
			// Special blocks must match both the mapped model name and model state
			else if (type = e_tl_type.SPECIAL_BLOCK && block.timeline)
				valid = (temp.model_name = block.tl_model_name && array_equals(temp.model_state, block_get_timeline_model_state(block, stateid)))
			
			// Return the original state
			if (valid)
				return [ block.block_id, stateid ]
		}
	}

	// Recover block data from the current special model
	if (type = e_tl_type.SPECIAL_BLOCK)
		return block_get_from_timeline(temp.model_name, temp.model_state)

	// Ordinary block timelines use their current template name and state
	var block = mc_assets.block_name_map[?temp.block_name];
	if (!is_undefined(block))
		return [ block.block_id, block_get_state_id(block, temp.block_state) ]

	return null
}
