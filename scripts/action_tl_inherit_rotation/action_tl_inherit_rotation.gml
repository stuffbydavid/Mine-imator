/// action_tl_inherit_rotation(enable)
/// @arg enable

if (history_undo)
{
	with (history_data)
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (iid_find(save_var_obj[t]))
			{
				inherit_rotation = other.save_var_oldval[t]
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
			with (iid_find(save_var_obj[t]))
			{
				inherit_rotation = other.save_var_newval[t]
				update_matrix = true
			}
		}
	}
}
else
{
	var hobj = history_save_var_start(action_tl_inherit_rotation, 0);
	
	with (obj_timeline)
	{
		if (!select)
			continue
			
		with (hobj)
			history_save_var(other.id, other.inherit_rotation, argument0)
			
		inherit_rotation = argument0
		update_matrix = true
	}
}

tl_update_matrix()
