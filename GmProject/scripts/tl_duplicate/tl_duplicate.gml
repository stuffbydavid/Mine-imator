/// @desc Duplicates the given timeline and children. Returns the new one.

function tl_duplicate()
{
	copy = new_obj(obj_timeline)
	tl_copy(copy)

	// Keep scenery texture defaults during manual copy
	if (block_timeline && !has_temp && part_of.copy = null)
	{
		if (type = e_tl_type.BLOCK)
		{
			copy.block_tex = temp_get_block_texobj(null)
			copy.block_tex_material = temp_get_block_tex_material_obj(null)
			copy.block_tex_normal = temp_get_block_tex_normal_obj(null)
		}
		else if (type = e_tl_type.SPECIAL_BLOCK)
		{
			copy.model_tex = temp_get_model_texobj(null)
			copy.model_tex_material = temp_get_model_tex_material_obj(null)
			copy.model_tex_normal = temp_get_model_tex_normal_obj(null)
		}
	}
	
	with (copy)
	{
		root_copy = null
		copy = null

		// Keep ownership within the duplicated hierarchy
		if (part_of != null)
			part_of = part_of.copy

		if (part_root != null)
			part_root = part_root.copy
		
		if (!has_temp && temp != null)
		{
			if (temp = other.id)
				temp = id
			else
				temp = temp.copy
		}

		tl_update_scenery_part()
		
		// Set correct template
		if (has_temp && temp != null)
		{
			if (temp.part_of != null) // Template is also a part, update to its copy
				temp = temp.copy
		}
		
		// Copy default values
		for (var v = 0; v < e_value.amount; v++)
		{
			value_default[v] = tl_value_find_save_id(v, null, other.value_default[v])
			if (!animated)
				value[v] = other.value[v]
		}
		
		// Copy keyframes
		for (var k = 0; k < ds_list_size(other.keyframe_list); k++)
		{
			var oldkf, newkf;
			oldkf = other.keyframe_list[|k]
			
			newkf = new_obj(obj_keyframe)
			newkf.position = oldkf.position
			newkf.timeline = id
			newkf.selected = false
			newkf.sound_play_index = null
			for (var v = 0; v < e_value.amount; v++)
				newkf.value[v] = oldkf.value[v]
			
			ds_list_add(keyframe_list, newkf)
		}
		
		// Copy tree structure
		for (var t = 0; t < ds_list_size(other.tree_list); t++)
		{
			with (other.tree_list[|t])
				ds_list_add(other.tree_list, tl_duplicate())
			
			tree_list[|t].parent = id
		}
		
		// Copy body part references
		if (other.part_list != null)
		{
			part_list = ds_list_create()
			for (var p = 0; p < ds_list_size(other.part_list); p++)
			{
				var pcopy = other.part_list[|p].copy;
				ds_list_add(part_list, pcopy)
				pcopy.part_of = id
			}
		}
		
		if (other.pattern_type != "" && other.pattern_base_color != null)
		{
			pattern_type = other.pattern_type
			pattern_base_color = other.pattern_base_color
			pattern_pattern_list = array_copy_1d(other.pattern_pattern_list)
			pattern_color_list = array_copy_1d(other.pattern_color_list)
			array_add(pattern_update, id)
		}
	
		if (type_is_light(type))
			tl_light_check_shadows()
		
		// Update
		tl_update()
		tl_update_values()
		
		return id
	}
}
