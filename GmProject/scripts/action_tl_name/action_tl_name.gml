/// action_tl_name(name)
/// @arg name

function action_tl_name(name)
{
	if (history_undo)
	{
		with (history_data) 
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					id.name = other.save_var_old_value[t]
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
				with (save_id_find(save_var_save_id[t]))
				{
					id.name = other.save_var_new_value[t]
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
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.name, name)
			
			id.name = name
			tl_update_display_name()
		}
	}
}
