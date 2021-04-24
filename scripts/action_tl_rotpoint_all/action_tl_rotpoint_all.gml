/// action_tl_rotpoint_all(point)
/// @arg point

function action_tl_rotpoint_all(point)
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					rot_point = other.save_var_old_value[t]
					tl_update_rot_point()
				}
			}
		}
	}
	else if (history_redo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					rot_point = other.save_var_new_value[t]
					tl_update_rot_point()
				}
			}
		}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_rotpoint_all, false);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.rot_point, point)
			
			rot_point = point
			tl_update_rot_point()
		}
	}
	
	tl_update_matrix()
}
