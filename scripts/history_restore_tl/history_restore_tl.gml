/// history_restore_tl(save)
/// @arg save
/// @desc Restores a saved timeline from memory.

var save, tl;
save = argument0
tl = new(obj_timeline)

with (save)
	tl_copy(tl)
	
with (tl)
{
	save_id = save.save_id
	temp = save_id_find(temp)
	if (temp && part_of = null)
		temp.count++
	
	// Restore values
	for (var v = 0; v < values; v++)
		value_default[v] = save.value_default[v]
	
	// Restore keyframes
	for (var k = 0; k < save.kf_amount; k++)
	{
		with (new(obj_keyframe))
		{
			position = save.kf_pos[k]
			timeline = tl
			selected = false
			sound_play_index = null
			for (var v = 0; v < values; v++)
				value[v] = tl_value_restore(v, null, save.kf_value[k, v])
			ds_list_add(other.keyframe_list, id)
		}
	}
	
	parent = save_id_find(parent)
	ds_list_insert(parent.tree_list, parent_index, id)
	
	part_of = save_id_find(part_of)
	if (part_of != null)
		ds_list_add(part_of.part_list, id)
		
	// Restore recursively
	for (var t = 0; t < save.tree_amount; t++)
		history_restore_tl(save.tree_save_obj[t])
		
	// Restore references
	for (var s = 0; s < save.usage_temp_shape_tex_amount; s++)
		with (save_id_find(save.usage_temp_shape_tex_save_id[s]))
			shape_tex = tl
		
	for (var s = 0; s < save.usage_tl_texture_amount; s++)
	{
		with (save_id_find(save.usage_tl_texture_save_id[s]))
		{
			value[TEXTUREOBJ] = tl
			update_matrix = true
		}
	}
			
	for (var s = 0; s < save.usage_tl_attractor_amount; s++)
	{
		with (save_id_find(save.usage_tl_attractor_save_id[s]))
		{
			value[ATTRACTOR] = tl
			update_matrix = true
		}
	}
			
	for (var s = 0; s < save.usage_kf_texture_amount; s++)
		with (save_id_find(save.usage_kf_texture_tl_save_id[s]))
			keyframe[save.usage_kf_texture_index[s]].value[TEXTUREOBJ] = tl
			
	for (var s = 0; s < save.usage_kf_attractor_amount; s++)
		with (save_id_find(save.usage_kf_attractor_tl_save_id[s]))
			keyframe[save.usage_kf_attractor_index[s]].value[ATTRACTOR] = tl

	// Update
	tl_update_type_name()
	tl_update_display_name()
	tl_update_rot_point()
	tl_update_value_types()
	tl_update_values()
	tl_update_depth()
	if (type = "particles")
		particle_spawner_init()
}

return tl
