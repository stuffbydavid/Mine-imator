/// action_tl_shadows(enable)
/// @arg enable

if (history_undo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (save_id_find(save_var_save_id[t]))
				shadows = other.save_var_old_value[t]
}
else if (history_redo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (save_id_find(save_var_save_id[t]))
				shadows = other.save_var_new_value[t]
}
else
{
	var hobj = history_save_var_start(action_tl_shadows, false);
	
	with (obj_timeline)
	{
		if (!selected)
			continue
			
		with (hobj)
			history_save_var(other.id, other.shadows, argument0)
			
		shadows = argument0
		
		with (obj_timeline)
		{
			if (tl_has_parent(other.id))
			{
				with (hobj)
					history_save_var(other.id, other.shadows, argument0)
					
				shadows = argument0
			}
		}
	}
}
