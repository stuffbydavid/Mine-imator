function action_tl_render_depth(value, add)
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					render_depth = other.save_var_old_value[t]
					tl_update_depth()
					view_changed()
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
					render_depth = other.save_var_new_value[t]
					tl_update_depth()
					view_changed()
				}
			}
		}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_render_depth, true);
		
		with (obj_timeline)
		{
			if (selected)
			{
				var newvalue = render_depth * add + value;
				with (hobj)
					history_save_var(other.id, other.render_depth, newvalue)
				
				render_depth = newvalue
				tl_update_depth()
				view_changed()
			}
		}
	}
}
