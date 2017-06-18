/// action_tl_name(name)
/// @arg name

if (history_undo)
{
	with (history_data) 
	{
		for (var t = 0; t < save_var_amount; t++)
		{
			with (iid_find(save_var_obj[t]))
			{
				name = other.save_var_oldval[t]
				tl_update_display_name()
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
				name = other.save_var_newval[t]
				tl_update_display_name()
			}
		}
	}
}
else
{
	var hobj = history_save_var_start(action_tl_name, true);
	
	with (obj_timeline)
	{
		if (!select)
			continue
			
		with (hobj)
			history_save_var(other.id, other.name, argument0)
			
		name = argument0
		tl_update_display_name()
	}
}
