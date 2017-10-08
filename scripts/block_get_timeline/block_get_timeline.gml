/// block_get_timeline(block, stateid)
/// @arg block
/// @arg stateid

var block, stateid;
block = argument0
stateid = argument1
/*
mc_builder.vars = array_copy_1d(state)

// Run block specific script, returns null to skip this block
if (block.type != null)
{
	var script = asset_get_index("block_set_" + block.type);
	if (script > -1)
	{
		var ret = script_execute(script);
		if (ret = null)
			return null
	}
}

with (new(obj_block_tl))
{
	id.block = block
	model_name = block.tl_model_name
	model_state = array()
	
	if (model_name != "")
	{
		if (!block.tl_has_model_state)
			model_state = array_copy_1d(state) // Copy block state if not specified
		else if (block.tl_model_state_amount = 0)
			model_state = array_copy_1d(block.tl_model_state)
		
		// Find model state from block state
		for (var i = 0; i < block.tl_model_state_amount; i++)
		{
			var curstate = block.tl_model_state[i];
			if (state_vars_match(curstate.vars, mc_builder.vars)) // Found matching state
			{
				model_state = array_copy_1d(curstate.value)
				break
			}
		}
	}
	
	// Get text from state
	has_text = block.tl_has_text
	if (has_text)
	{
		text = state_vars_get_value(mc_builder.vars, "text")
		if (text = null)
			text = ""
		text_position = block.tl_text_position
	}
	
	rot_point = block.tl_rot_point
	position = block.tl_position
	rotation = block.tl_rotation
	
	// Find rotation point from state
	for (var i = 0; i < block.tl_rot_point_state_amount; i++)
	{
		var curstate = block.tl_rot_point_state[i];
		if (state_vars_match(curstate.vars, mc_builder.vars)) // Found matching state
		{
			rot_point = curstate.value
			break
		}
	}
	
	// Find position from state
	for (var i = 0; i < block.tl_position_state_amount; i++)
	{
		var curstate = block.tl_position_state[i];
		if (state_vars_match(curstate.vars, mc_builder.vars)) // Found matching state
		{
			position = curstate.value
			break
		}
	}
	
	// Find rotation point from state
	for (var i = 0; i < block.tl_rotation_state_amount; i++)
	{
		var curstate = block.tl_rotation_state[i];
		if (state_vars_match(curstate.vars, mc_builder.vars)) // Found matching state
		{
			rotation = curstate.value
			break
		}
	}

	position = point3D_add(other.block_pos, position)
	return id
}*/