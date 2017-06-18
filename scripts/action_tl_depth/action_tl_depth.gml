/// action_tl_depth(value, add)
/// @arg value
/// @arg add

if (history_undo)
{
	with (history_data)
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (iid_find(save_var_obj[t]))
			{
				depth = other.save_var_oldval[t]
				tl_update_depth()
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
			with (iid_find(save_var_obj[t]))
			{
				depth = other.save_var_newval[t]
				tl_update_depth()
			}
		}
	}
}
else
{
	var hobj = history_save_var_start(action_tl_depth, true);
	
	with (obj_timeline)
	{
		if (!select)
			continue
			
		with (hobj)
			history_save_var(other.id, other.depth, other.depth * argument1 + argument0)
			
		depth = depth * argument1 + argument0
		tl_update_depth()
		
		with (obj_timeline)
		{
			if (tl_has_parent(other.id))
			{
				with (hobj)
					history_save_var(other.id, other.depth, other.depth * argument1 + argument0)
					
				depth = depth * argument1 + argument0
				tl_update_depth()
			}
		}
	}
}
