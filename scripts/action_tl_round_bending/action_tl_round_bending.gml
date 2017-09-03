/// action_tl_round_bending(enable)		
/// @arg enable

if (history_undo)
{
	with (history_data)
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (save_id_find(save_var_save_id[t]))
			{
				round_bending = other.save_var_old_value[t]
				tl_update_bend(true)
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
				round_bending = other.save_var_new_value[t]
				tl_update_bend(true)
			}
		}
	}
}
else
{
	var hobj = history_save_var_start(action_tl_round_bending, false);
	
	with (obj_timeline)
	{
		if (!selected)
			continue
			
		with (hobj)
			history_save_var(other.id, other.round_bending, argument0)
			
		round_bending = argument0
		tl_update_bend(true)
	}
}
