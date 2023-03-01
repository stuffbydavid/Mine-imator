/// block_get_timeline(block, stateid)
/// @arg block
/// @arg stateid

function block_get_timeline(block, stateid)
{
	var pos = build_pos;
	
	with (new_obj(obj_block_tl))
	{
		id.block = block
		model_name = block.tl_model_name
		model_state = array()
		
		if (model_name != "")
		{
			if (!block.tl_has_model_state)
				model_state = block_get_state_id_state_vars(block, stateid) // Copy block state if not specified
			else if (block.tl_model_state_amount = 0)
				model_state = array_copy_1d(block.tl_model_state)
			
			// Find model state from block state
			for (var i = 0; i < block.tl_model_state_amount; i++)
			{
				var curstate = block.tl_model_state[i];
				if (array_contains(curstate.state_id, stateid)) // Found matching state
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
			text = mc_builder.block_text_map[?pos]
			text_color = mc_builder.block_text_color_map[?pos]
			if (is_undefined(text))
			{
				text = ""
				text_color = c_black
			}
			
			text_position = block.tl_text_position
			text_scale = block.tl_text_scale
		}
		
		// Get banner patterns
		pattern_type = block.tl_pattern_type
		if (pattern_type != "")
		{
			banner_color = mc_builder.block_banner_color_map[?pos]
			banner_patterns = mc_builder.block_banner_patterns_map[?pos]
			banner_pattern_colors = mc_builder.block_banner_pattern_colors_map[?pos]
			if (is_undefined(banner_color))
			{
				banner_color = c_white
				banner_patterns = array()
				banner_pattern_colors = array()
			}
		}
		
		// Skull resource
		if (mc_builder.block_skull_map[?pos] != undefined)
		{
			var userid = mc_builder.block_skull_map[?pos];
			texture =  mc_builder.block_skull_res_map[?userid]
		}
		else
			texture = null
		
		rot_point = block.tl_rot_point
		position = block.tl_position
		rotation = block.tl_rotation
		
		// Find rotation point from state
		for (var i = 0; i < block.tl_rot_point_state_amount; i++)
		{
			var curstate = block.tl_rot_point_state[i];
			if (array_contains(curstate.state_id, stateid)) // Found matching state
			{
				rot_point = curstate.value
				break
			}
		}
		
		// Find position from state
		for (var i = 0; i < block.tl_position_state_amount; i++)
		{
			var curstate = block.tl_position_state[i];
			if (array_contains(curstate.state_id, stateid)) // Found matching state
			{
				position = curstate.value
				break
			}
		}
		
		// Find rotation point from state
		for (var i = 0; i < block.tl_rotation_state_amount; i++)
		{
			var curstate = block.tl_rotation_state[i];
			if (array_contains(curstate.state_id, stateid)) // Found matching state
			{
				rotation = curstate.value
				break
			}
		}
		
		// Add current position in terrain
		position[X] += other.build_pos_x * block_size
		position[Y] += other.build_pos_y * block_size
		position[Z] += other.build_pos_z * block_size
		
		// Get variant
		variant = block_get_state_id_value(block, stateid, "variant")
		
		return id
	}
}
