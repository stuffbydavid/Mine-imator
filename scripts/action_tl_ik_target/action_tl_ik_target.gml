/// action_tl_ik_target(target)
/// @arg target

function action_tl_ik_target(target)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_target = save_id_find(other.save_var_old_value[t])
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					id.ik_target = save_id_find(other.save_var_new_value[t])
	}
	else
	{
		var hobj = history_save_var_start(action_tl_ik_target, true);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, save_id_get(other.ik_target), save_id_get(target))
			
			id.ik_target = target
		}
	}
	
	tl_update_list()
	tl_update_matrix()
}
