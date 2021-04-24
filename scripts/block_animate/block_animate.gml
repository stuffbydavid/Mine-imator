/// block_animate(root)
/// @arg root

function block_animate(root)
{
	// Create timeline
	with (new_obj(obj_timeline))
	{
		temp = id
		
		// Set to be a part of scenery
		inherit_rot_point = true
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
				state_vars_add(block_state, array("variant", other.variant))
			tl_update_scenery_part()
			
			texture_filtering = true
		}
		
		// Rotation point
		rot_point_custom = true
		rot_point = array_copy_1d(other.rot_point)
		
		// Position & rotation
		if (!dev_mode || dev_mode_rotate_blocks)
		{
			var pos = point3D_mul_matrix(other.position, matrix_create(point3D(0, root.temp.scenery.scenery_size[Y] * block_size, 0), vec3(0, 0, 90), vec3(1)))
			value_default[e_value.POS_X] = snap(pos[X], 0.01)
			value_default[e_value.POS_Y] = snap(pos[Y], 0.01)
			value_default[e_value.POS_Z] = snap(pos[Z], 0.01)
			value_default[e_value.ROT_X] = other.rotation[X]
			value_default[e_value.ROT_Y] = other.rotation[Y]
			value_default[e_value.ROT_Z] = other.rotation[Z] + 90
		}
		else
		{
			value_default[e_value.POS_X] = other.position[X]
			value_default[e_value.POS_Y] = other.position[Y]
			value_default[e_value.POS_Z] = other.position[Z]
			value_default[e_value.ROT_X] = other.rotation[X]
			value_default[e_value.ROT_Y] = other.rotation[Y]
			value_default[e_value.ROT_Z] = other.rotation[Z]
		}
		
		// Texture
		if (other.texture != null)
		{
			value_default[e_value.TEXTURE_OBJ] = other.texture
			value_default[e_value.TEXTURE_OBJ].count++
		}
		
		tl_update()
		tl_update_values()
		
		// Add text
		if (other.has_text)
		{
			var text, textpos, textcolor;
			text = other.text
			textpos = other.text_position
			textcolor = other.text_color
			
			if (part_list = null)
				part_list = ds_list_create()
			
			with (new_obj(obj_timeline))
			{
				type = e_tl_type.TEXT
				temp = id
				
				// Set parent to other timeline
				inherit_rot_point = true
				part_of = other.id
				ds_list_add(other.part_list, id)
				tl_set_parent(other.id)
				
				id.text = text
				tl_update_scenery_part()
				
				value_default[e_value.POS_X] = textpos[X]
				value_default[e_value.POS_Y] = textpos[Y]
				value_default[e_value.POS_Z] = textpos[Z]
				value_default[e_value.SCA_X] = 0.165
				value_default[e_value.SCA_Y] = 0.165
				value_default[e_value.SCA_Z] = 0.165
				value_default[e_value.RGB_MUL] = textcolor
				
				tl_update()
				tl_update_values()
			}
		}
		
		// Pass in banner data
		if (other.is_banner)
		{
			banner_base_color = other.banner_color
			banner_pattern_list = array_copy_1d(other.banner_patterns)
			banner_color_list = array_copy_1d(other.banner_pattern_colors)
			
			is_banner = true
			
			var stand = tree_list[|0];
			stand.banner_skin = banner_skin
			stand.is_banner = true
			
			var banner = stand.tree_list[|0];
			banner.banner_skin = banner_skin
			banner.is_banner = true
			
			// Update
			array_add(banner_update, id)
		}
	}
}
