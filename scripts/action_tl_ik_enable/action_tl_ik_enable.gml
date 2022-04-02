/// action_tl_ik_enable(enable)
/// @arg enable

function action_tl_ik_enable(enable)
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					id.ik_enable = other.save_var_old_value[t]
					update_matrix = true
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
					id.ik_enable = other.save_var_new_value[t]
					update_matrix = true
				}
			}
		}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_ik_enable, true);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.ik_enable, enable)
			
			id.ik_enable = enable
			
			update_matrix = true
		}
	}
	
	tl_update_matrix()
}
