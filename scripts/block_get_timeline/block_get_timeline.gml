/// block_get_timeline(block, stateid)
/// @arg block
/// @arg stateid

function block_get_timeline(block, stateid)
{
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
			with (mc_builder)
			{
				var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
				other.text = block_text_map[?ind]
				other.text_color = block_text_color_map[?ind]
				if (is_undefined(other.text))
				{
					other.text = ""
					other.text_color = c_black
				}
			}
			
			text_position = block.tl_text_position
		}
		
		// Get banner patterns
		is_banner = block.tl_is_banner
		if (is_banner)
		{
			with (mc_builder)
			{
				var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
				other.banner_color = block_banner_color_map[?ind]
				other.banner_patterns = block_banner_patterns_map[?ind]
				other.banner_pattern_colors = block_banner_pattern_colors_map[?ind]
			}
		}
		
		// Skull resource
		with (mc_builder)
		{
			var ind = builder_get_index(build_pos_x, build_pos_y, build_pos_z);
			
			if (block_skull_map[?ind] != undefined)
			{
				var userid = block_skull_map[?ind];
				other.texture = block_skull_res_map[?userid]
			}
			else
				other.texture = null
		}
		
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
		position[X] += mc_builder.build_pos_x * block_size
		position[Y] += mc_builder.build_pos_y * block_size
		position[Z] += mc_builder.build_pos_z * block_size
		
		// Get variant
		variant = block_get_state_id_value(block, stateid, "variant")
		
		return id
	}
}
