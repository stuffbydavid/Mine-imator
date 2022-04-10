/// history_restore_tl(save)
/// @arg save
/// @desc Restores a saved timeline from memory.

function history_restore_tl(save)
{
	var tl = new_obj(obj_timeline);
	
	with (save)
		tl_copy(tl)
	
	with (tl)
	{
		save_id = save.save_id
		tl_find_save_ids()
		
		if (temp != null && part_of = null)
			temp.count++
		
		// Restore default values
		for (var v = 0; v < e_value.amount; v++)
			value_default[v] = tl_value_find_save_id(v, null, save.value_default[v])
		
		// Restore keyframes
		for (var k = 0; k < save.kf_amount; k++)
		{
			with (new_obj(obj_keyframe))
			{
				position = save.kf_pos[k]
				timeline = tl
				selected = false
				sound_play_index = null
				for (var v = 0; v < e_value.amount; v++)
					value[v] = tl_value_find_save_id(v, null, save.kf_value[k, v])
				ds_list_add(other.keyframe_list, id)
			}
		}
		
		ds_list_insert(parent.tree_list, parent_tree_index, id)
		
		// Restore banner data
		if (save.is_banner)
		{
			is_banner = true
			banner_base_color = save.banner_base_color
			banner_pattern_list = array_copy_1d(save.banner_pattern_list)
			banner_color_list = array_copy_1d(save.banner_color_list)
			array_add(banner_update, id)
		}
		
		// Update
		tl_update_scenery_part()
		tl_update()
		tl_update_values()
		
		// Restore tree recursively
		for (var t = 0; t < save.tree_amount; t++)
			history_restore_tl(save.tree_save_obj[t])
		
		// Restore parts
		if (save.part_amount > 0)
			part_list = ds_list_create()
		
		for (var p = 0; p < save.part_amount; p++)
			ds_list_add(part_list, save_id_find(save.part_save_id[p]))
		
		// Restore references
		for (var s = 0; s < save.usage_temp_shape_tex_amount; s++)
			with (save_id_find(save.usage_temp_shape_tex_save_id[s]))
				shape_tex = tl
		
		for (var s = 0; s < save.usage_temp_path_amount; s++)
			with (save_id_find(save.usage_temp_path_save_id[s]))
				pc_spawn_region_path = tl
		
		for (var s = 0; s < save.usage_tl_texture_amount; s++)
		{
			with (save_id_find(save.usage_tl_texture_save_id[s]))
			{
				value[e_value.TEXTURE_OBJ] = tl
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_path_amount; s++)
		{
			with (save_id_find(save.usage_tl_path_save_id[s]))
			{
				value[e_value.PATH_OBJ] = tl
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_attractor_amount; s++)
		{
			with (save_id_find(save.usage_tl_attractor_save_id[s]))
			{
				value[e_value.ATTRACTOR] = tl
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_ik_target_amount; s++)
		{
			with (save_id_find(save.usage_tl_ik_target_save_id[s]))
			{
				value[e_value.IK_TARGET] = tl
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_tl_ik_target_angle_amount; s++)
		{
			with (save_id_find(save.usage_tl_ik_target_angle_save_id[s]))
			{
				value[e_value.IK_TARGET_ANGLE] = tl
				update_matrix = true
			}
		}
		
		for (var s = 0; s < save.usage_kf_texture_amount; s++)
			with (save_id_find(save.usage_kf_texture_tl_save_id[s]))
				keyframe_list[|save.usage_kf_texture_index[s]].value[e_value.TEXTURE_OBJ] = tl
		
		for (var s = 0; s < save.usage_kf_path_amount; s++)
			with (save_id_find(save.usage_kf_path_tl_save_id[s]))
				keyframe_list[|save.usage_kf_path_index[s]].value[e_value.PATH_OBJ] = tl
		
		for (var s = 0; s < save.usage_kf_attractor_amount; s++)
			with (save_id_find(save.usage_kf_attractor_tl_save_id[s]))
				keyframe_list[|save.usage_kf_attractor_index[s]].value[e_value.ATTRACTOR] = tl
		
		for (var s = 0; s < save.usage_kf_ik_target_amount; s++)
			with (save_id_find(save.usage_kf_ik_target_tl_save_id[s]))
				keyframe_list[|save.usage_kf_ik_target_index[s]].value[e_value.IK_TARGET] = tl
		
		for (var s = 0; s < save.usage_kf_ik_target_angle_amount; s++)
			with (save_id_find(save.usage_kf_ik_target_angle_tl_save_id[s]))
				keyframe_list[|save.usage_kf_ik_target_angle_index[s]].value[e_value.IK_TARGET_ANGLE] = tl
	}
	
	return tl
}
