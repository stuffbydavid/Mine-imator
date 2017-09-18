/// block_get_timeline(block, state)
/// @arg block
/// @arg state

var block, state;
block = argument0
state = argument1

ds_map_clear(mc_builder.vars)
state_vars_string_to_map(state, mc_builder.vars)

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
	model_state = ""
	
	if (model_name != "")
	{
		if (!block.tl_has_model_state)
			model_state = state // Copy block state if not specified
		else if (block.tl_model_state_amount = 0)
			model_state = block.tl_model_state
		
		// Find model state from block state
		for (var i = 0; i < block.tl_model_state_amount; i++)
		{
			var curstate = block.tl_model_state[i];
			if (state_vars_match(curstate.state_map, mc_builder.vars)) // Found matching state
			{
				model_state = curstate.value
				break
			}
		}
	}
	
	// Get text from state
	has_text = block.tl_has_text
	if (has_text)
	{
		text = mc_builder.vars[?"text"]
		text_position = block.tl_text_position
		
		// Un-escape = and ,
		text = string_replace_all(text, "\\=", "=")
		text = string_replace_all(text, "\\,", ",")
	}
	
	rot_point = block.tl_rot_point
	position = block.tl_position
	rotation = block.tl_rotation
	
	// Find rotation point from state
	for (var i = 0; i < block.tl_rot_point_state_amount; i++)
	{
		var curstate = block.tl_rot_point_state[i];
		if (state_vars_match(curstate.state_map, mc_builder.vars)) // Found matching state
		{
			rot_point = curstate.value
			break
		}
	}
	
	// Find position from state
	for (var i = 0; i < block.tl_position_state_amount; i++)
	{
		var curstate = block.tl_position_state[i];
		if (state_vars_match(curstate.state_map, mc_builder.vars)) // Found matching state
		{
			position = curstate.value
			break
		}
	}
	
	// Find rotation point from state
	for (var i = 0; i < block.tl_rotation_state_amount; i++)
	{
		var curstate = block.tl_rotation_state[i];
		if (state_vars_match(curstate.state_map, mc_builder.vars)) // Found matching state
		{
			rotation = curstate.value
			break
		}
	}

	position = point3D_add(other.block_pos, position)
	return id
}