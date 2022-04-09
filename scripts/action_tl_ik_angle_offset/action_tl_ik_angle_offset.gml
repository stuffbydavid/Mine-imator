/// action_tl_ik_angle_offset(value, add)
/// @arg value
/// @arg add

function action_tl_ik_angle_offset(value, add)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_angle_offset = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_angle_offset = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_ik_angle_offset, true);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.ik_angle_offset, other.ik_angle_offset * add + value)
			
			id.ik_angle_offset = id.ik_angle_offset * add + value
		}
	}
	
	tl_update_matrix()
}
