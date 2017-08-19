/// action_tl_keyframes_move_done()

if (history_undo)
{
	with (history_data)
	{
		for (var k = 0; k < kf_move_amount; k++) // Move back keyframes
		{
			with (save_id_find(kf_move_tl_save_id[k]).keyframe_list[|kf_move_new_index[k]])
			{
				new_position = other.kf_move_old_pos[k]
				if (position = new_position)
					continue
				
				ds_list_delete_value(timeline.keyframe_list, id)
				
				for (var a = 0; a < other.kf_move_amount; a++)  // Push down other indices of same timeline
					if (save_id_find(other.kf_move_tl_save_id[a]) = timeline && other.kf_move_new_index[a] > index)
						other.kf_move_new_index[a]--
			}
		}
	}
}
else if (history_redo)
{
	with (history_data)
	{
		for (var k = 0; k < kf_move_amount; k++) // Move forward keyframes
		{
			with (save_id_find(kf_move_tl[k]).keyframe[kf_move_old_index[k]])
			{
				new_position = other.kf_move_new_pos[k]
				if (position = new_position)
					continue
				
				ds_list_delete_value(timeline.keyframe_list, id)
				
				for (var a = 0; a < other.kf_move_amount; a++) // Push down other indices of same timeline
					if (save_id_find(other.kf_move_tl_save_id[a]) = timeline && other.kf_move_old_index[a] > index)
						other.kf_move_old_index[a]--
			}
		}
	}
}
else
{
	with (history_set(action_tl_keyframes_move_done))
	{
		kf_move_amount = 0
		with (obj_keyframe)
		{
			if (!selected)
				continue
			
			other.kf_move_tl_save_id[other.kf_move_amount] = save_id_get(timeline)
			other.kf_move_old_index[other.kf_move_amount] = move_index
			other.kf_move_old_pos[other.kf_move_amount] = move_position
			other.kf_move_new_index[other.kf_move_amount] = ds_list_find_index(timeline.keyframe_list, id)
			other.kf_move_new_pos[other.kf_move_amount] = position
			other.kf_move_amount++
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
		{
			tl_keyframe_add(other.new_position, other.id)
			update_matrix = true
		}
	}
}

tl_update_length()
