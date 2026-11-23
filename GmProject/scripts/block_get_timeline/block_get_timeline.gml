/// @desc Returns an object with block timeline data.
/// @arg block
/// @arg stateid

function block_get_timeline(block, stateid)
{
	var pos = build_pos_index;
	
	with (new_obj(obj_block_tl))
	{
		self.block = block
		
		block_build_name = block.name
		block_build_state = block_get_state_id_state_vars(block, stateid)
		
		render_state = block_get_timeline_render_state(block, stateid)
		
		model_name = block.tl_model_name
		model_state = block_get_timeline_model_state(block, stateid)
		
		animated = block.tl_animated
		animated_parts = block.tl_animated_parts
		
		if (model_name != "")
		{
			// Unique case with decorated pot
			if (!is_undefined(mc_builder.block_decorated_pot_sherds_map[?pos]))
				model_state = array_copy_1d(mc_builder.block_decorated_pot_sherds_map[?pos])
		}
		
		// Get text from state
		has_text = block.tl_has_text
		if (has_text)
		{
			text_front = mc_builder.block_text_front_map[?pos]
			text_front_color = mc_builder.block_text_front_color_map[?pos]
			text_front_glow_color = mc_builder.block_text_front_glow_color_map[?pos]
			text_front_emissive = mc_builder.block_text_front_glowing_map[?pos]
			text_back = mc_builder.block_text_back_map[?pos]
			text_back_color = mc_builder.block_text_back_color_map[?pos]
			text_back_glow_color = mc_builder.block_text_back_glow_color_map[?pos]
			text_back_emissive = mc_builder.block_text_back_glowing_map[?pos]
			
			if (is_undefined(text_front))
			{
				text_front = ""
				text_front_color = c_black
				text_front_glow_color = c_black
				text_front_emissive = 0
			}
			
			if (is_undefined(text_back))
			{
				text_back = ""
				text_back_color = c_black
				text_back_glow_color = c_black
				text_back_emissive = 0
			}
			
			text_front_position = block.tl_text_front_position
			text_front_rotation = block.tl_text_front_rotation
			text_front_scale = block.tl_text_front_scale
			text_back_position = block.tl_text_back_position
			text_back_rotation = block.tl_text_back_rotation
			text_back_scale = block.tl_text_back_scale
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
				banner_patterns = []
				banner_pattern_colors = []
			}
		}
		
		// Skull resource
		if (!is_undefined(mc_builder.block_skull_map[?pos]))
		{
			var userid = mc_builder.block_skull_map[?pos];
			texture = mc_builder.block_skull_res_map[?userid]
		}
		else
			texture = null
		
		rot_point = block_get_timeline_rot_point(block, stateid)
		position = block_get_timeline_position(block, stateid)
		rotation = block_get_timeline_rotation(block, stateid)
		
		// Add current position in terrain
		position = vec3_add(position, vec3_mul(other.build_pos, block_size))
		
		// Get variant
		variant = block_get_state_id_value(block, stateid, "variant")
		
		return id
	}
}
