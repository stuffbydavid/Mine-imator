/// action_tl_keyframes_sound_resize_done()

function action_tl_keyframes_sound_resize_done()
{
	with (obj_timeline)
		update_values = false
	
	if (history_undo)
	{
		with (history_data) 
		{
			// Move back keyframes
			for (var k = 0; k < kf_resize_amount; k++) 
			{
				with (save_id_find(kf_resize_tl_save_id[k]).keyframe_list[|kf_resize_new_index[k]])
				{
					new_position = other.kf_resize_old_pos[k]
					if (position = new_position)
						continue
					
					value[e_value.SOUND_START] = other.kf_resize_old_start[k]
					
					// Push down other indices of same timeline
					for (var a = 0; a < other.kf_resize_amount; a++)
						if (save_id_find(other.kf_resize_tl_save_id[a]) = timeline && other.kf_resize_new_index[a] > ds_list_find_index(timeline.keyframe_list, id))
							other.kf_resize_new_index[a]--
					
					ds_list_delete_value(timeline.keyframe_list, id)
					timeline.update_values = true
				}
			}
		}
	}
	else if (history_redo)
	{
		with (history_data)
		{
			// Move forward keyframes
			for (var k = 0; k < kf_resize_amount; k++) 
			{
				with (save_id_find(kf_resize_tl_save_id[k]).keyframe_list[|kf_resize_old_index[k]])
				{
					new_position = other.kf_resize_new_pos[k]
					if (position = new_position)
						continue
					
					value[e_value.SOUND_START] = other.kf_resize_new_start[k]
					
					// Push down other indices of same timeline
					for (var a = 0; a < other.kf_resize_amount; a++)
						if (save_id_find(other.kf_resize_tl_save_id[a]) = timeline && other.kf_resize_old_index[a] > ds_list_find_index(timeline.keyframe_list, id))
							other.kf_resize_old_index[a]--
					
					ds_list_delete_value(timeline.keyframe_list, id)
					timeline.update_values = true
				}
			}
		}
	}
	else
	{
		with (history_set(action_tl_keyframes_sound_resize_done))
		{
			kf_resize_amount = 0
			with (obj_keyframe)
			{
				if (!selected || sound_resize_index < 0)
					continue
				
				other.kf_resize_tl_save_id[other.kf_resize_amount] = save_id_get(timeline)
				other.kf_resize_old_index[other.kf_resize_amount] = sound_resize_index
				other.kf_resize_old_pos[other.kf_resize_amount] = sound_resize_pos
				other.kf_resize_old_start[other.kf_resize_amount] = sound_resize_start
				other.kf_resize_new_index[other.kf_resize_amount] = ds_list_find_index(timeline.keyframe_list, id)
				other.kf_resize_new_pos[other.kf_resize_amount] = position
				other.kf_resize_new_start[other.kf_resize_amount] = value[e_value.SOUND_START]
				other.kf_resize_amount++
				timeline.update_values = true
			}
		}
		window_busy = ""
	}
	
	if (history_undo || history_redo)
	{
		with (obj_keyframe)
		{
			if (!selected || position = new_position)
				continue
			
			with (timeline)
				tl_keyframe_add(other.new_position, other.id)
		}
	}
	
	tl_update_length()
	
	with (obj_timeline)
		if (update_values)
			tl_update_values()
}
