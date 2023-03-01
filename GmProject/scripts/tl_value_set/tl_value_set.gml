/// tl_value_set(valueid, value, add, [multiply])
/// @arg valueid
/// @arg value
/// @arg add
/// @arg [multiply]
/// @desc Adds the given value to all selected timelines.

function tl_value_set()
{
	if (history_undo)
	{
		// Remove keyframes
		for (var k = 0; k < history_data.kf_add_amount; k++)
			with (save_id_find(history_data.kf_add_tl_save_id[k]))
				with (keyframe_list[|history_data.kf_add_index[k]])
					instance_destroy()
		
		// Restore keyframes
		for (var k = 0; k < history_data.kf_set_amount; k++)
		{
			var kflist = save_id_find(history_data.kf_set_tl_save_id[k]).keyframe_list;
			var kfindex = history_data.kf_set_index[k];
			if (kfindex < ds_list_size(kflist))
			{
				with (kflist[|kfindex])
					for (var v = 0; v < history_data.par_set_amount; v++)
						value[history_data.value[v]] = tl_value_find_save_id(history_data.value[v], history_data.kf_set_new_value[k, v], history_data.kf_set_old_value[k, v])
			}
		}
	}
	else if (history_redo)
	{
		// Add keyframes
		for (var k = 0; k < history_data.kf_add_amount; k++)
			with (save_id_find(history_data.kf_add_tl_save_id[k]))
				tl_keyframe_add(history_data.kf_add_pos[k])
		
		// Restore keyframes
		for (var k = 0; k < history_data.kf_set_amount; k++)
			with (save_id_find(history_data.kf_set_tl_save_id[k]).keyframe_list[|history_data.kf_set_index[k]])
				for (var v = 0; v < history_data.par_set_amount; v++) 
					value[history_data.value[v]] = tl_value_find_save_id(history_data.value[v], history_data.kf_set_old_value[k, v], history_data.kf_set_new_value[k, v])
	}
	else
	{
		var vid, val, add, mul, tlcount;
		vid = argument[0]
		val = argument[1]
		add = argument[2]
		mul = (argument_count > 3 ? argument[3] : false)
		tlcount = 0
		
		// Modify timelines
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			if (history_data.scale_link_drag)
			{
				if (history_data.par_set_n = history_data.par_set_amount)
					history_data.tl_set_old_value[tlcount, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])
				
				value[vid] = history_data.tl_set_old_value[tlcount, history_data.par_set_n]
			}
			
			if (vid = e_value.SOUND_OBJ && value[e_value.SOUND_OBJ] != null)
				value[e_value.SOUND_OBJ].count--
			
			var nval;
			if (tl_value_is_string(vid) || tl_value_is_texture(vid) || tl_value_is_obj(vid))
				nval = val
			else if (mul)
				nval = value[vid] * val;
			else
				nval = value[vid] * add + val;
			
			if (value[vid] != nval)
				update_matrix = true
			
			value[vid] = tl_value_clamp(vid, nval)
			
			if (vid = e_value.SOUND_OBJ && value[e_value.SOUND_OBJ] != null)
				value[e_value.SOUND_OBJ].count++
			
			tlcount++
		}
		
		// Save and modify keyframes
		for (var k = 0; k < history_data.kf_set_amount; k++)
		{
			with (save_id_find(history_data.kf_set_tl_save_id[k]).keyframe_list[|history_data.kf_set_index[k]])
			{
				if (history_data.par_set_n = history_data.par_set_amount)
					history_data.kf_set_old_value[k, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])
				
				if (history_data.scale_link_drag)
					value[vid] = history_data.kf_set_old_value[k, history_data.par_set_n]
				
				var nval;
				if (tl_value_is_string(vid) || tl_value_is_texture(vid) || tl_value_is_obj(vid))
					nval = val
				else if (mul)
					nval = value[vid] * val;
				else
					nval = value[vid] * add + val;
				
				value[vid] = tl_value_clamp(vid, nval)
				
				history_data.kf_set_new_value[k, history_data.par_set_n] = tl_value_get_save_id(vid, value[vid])
			}
		}
		
		history_data.value[history_data.par_set_n] = vid
		history_data.par_set_n++
		history_data.par_set_amount = max(history_data.par_set_amount, history_data.par_set_n)
		
		return 0
	}
	
	// For undo / redo
	with (obj_timeline)
	{
		cam_goalzoom = null
		tl_update_values()
	}
		
	with (app)
	{
		tl_update_length()
		tl_update_matrix()
		app_update_tl_edit()
	}
}
