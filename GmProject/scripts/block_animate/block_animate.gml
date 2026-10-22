function block_animate(root)
{
	// Create timeline
	with (new_obj(obj_timeline))
	{
		temp = id
		has_temp = false
		
		// Set to be a part of scenery
		inherit_rot_point = true
		inherit_alpha = true
		inherit_color = true
		inherit_texture = true
		
		part_of = root
		part_root = root
		
		ds_list_add(root.part_list, id)
		tl_set_parent(root)
		
		// Special block
		if (other.model_name != "")
		{
			type = e_tl_type.SPECIAL_BLOCK
			
			model_name = other.model_name
			model_state = array_copy_1d(other.model_state)
			
			tl_update_scenery_part()
			
			// Add model parts
			part_list = ds_list_create()
			if (model_file != null)
			{
				for (var p = 0; p < ds_list_size(model_file.file_part_list); p++)
				{
					var partl = tl_new_part(model_file.file_part_list[|p]);
					partl.part_root = root
					ds_list_add(part_list, partl)
				}
				
				tl_update_part_list(model_file, id)
			}
		}
		
		// Block
		else
		{
			type = e_tl_type.BLOCK
			
			block_name = other.block.name
			block_state = array_copy_1d(other.block.default_state)
			
			if (is_string(other.variant))
				state_vars_add(block_state, [ "variant", other.variant ])
			
			tl_update_scenery_part()
			
			texture_filtering = true
		}
		
		// Rotation point
		rot_point_custom = true
		rot_point = array_copy_1d(other.rot_point)
		
		// Position & rotation
		var pos = point3D(
			other.position[Y],
			root.temp.scenery.scenery_size[Y] * block_size - other.position[X], other.position[Z]
		);
		value_default[e_value.POS_X] = snap(pos[X], 0.01)
		value_default[e_value.POS_Y] = snap(pos[Y], 0.01)
		value_default[e_value.POS_Z] = snap(pos[Z], 0.01)
		value_default[e_value.ROT_X] = other.rotation[X]
		value_default[e_value.ROT_Y] = other.rotation[Y]
		value_default[e_value.ROT_Z] = other.rotation[Z] + 90
		
		// Texture
		if (other.texture != null)
			value_default[e_value.TEXTURE_OBJ] = other.texture
		
		tl_update()
		tl_update_values()
		
		animated = false
		
		// Add text
		if (other.has_text)
		{
			if (part_list = null)
				part_list = ds_list_create()

			var textparent = tl_part_find("sign");
			if (textparent = null)
				textparent = id

			// Front
			block_animate_text(
				other.text_front, other.text_front_position, other.text_front_rotation, other.text_front_scale,
				other.text_front_color, other.text_front_glow_color, other.text_front_emissive, textparent
			)

			// Back
			block_animate_text(
				other.text_back, other.text_back_position, other.text_back_rotation, other.text_back_scale,
				other.text_back_color, other.text_back_glow_color, other.text_back_emissive, textparent
			)
		}
		
		// Pass in pattern data
		if (other.pattern_type != "")
		{
			pattern_base_color = other.banner_color
			pattern_pattern_list = array_copy_1d(other.banner_patterns)
			pattern_color_list = array_copy_1d(other.banner_pattern_colors)
			
			pattern_type = other.pattern_type
			
			if (pattern_type = "banner")
			{
				var stand = tree_list[|0];
				stand.pattern_skin = pattern_skin
				stand.pattern_type = "banner"
				
				var banner = stand.tree_list[|0];
				banner.pattern_skin = pattern_skin
				banner.pattern_type = "banner"
			}
			
			// Update
			array_add(pattern_update, id)
		}
	}
}
