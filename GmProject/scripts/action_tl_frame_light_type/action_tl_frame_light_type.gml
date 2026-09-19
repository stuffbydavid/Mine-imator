/// action_tl_frame_light_type(mode)
/// @arg mode

function action_tl_frame_light_type(mode)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
				{
					type = other.save_var_old_value[t]
					render_samples = -1
				}
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
				{
					type = other.save_var_new_value[t]
					render_samples = -1
				}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_frame_light_type, false);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.type, mode)
			
			type = mode
			render_samples = -1
		}
	}
	
	with (tl_edit)
	{
		tl_update_value_types()
		tl_update_display_name()
		tl_update_type_name()
	}
	
	app_update_tl_edit()
}
