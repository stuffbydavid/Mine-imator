/// action_tl_ik_pole_target(pole_target)
/// @arg pole_target

function action_tl_ik_pole_target(pole_target)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_pole_target = save_id_find(other.save_var_old_value[t])
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_pole_target = save_id_find(other.save_var_new_value[t])
	}
	else
	{
		var hobj = history_save_var_start(action_tl_ik_pole_target, true);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, save_id_get(other.ik_pole_target), save_id_get(pole_target))
			
			id.ik_pole_target = pole_target
		}
	}
	
	tl_update_list()
	tl_update_matrix()
}
