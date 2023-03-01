/// action_tl_wind_terrain(enable)
/// @arg enable

function action_tl_wind_terrain(enable)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					wind_terrain = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					wind_terrain = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_wind_terrain, false);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.wind_terrain, enable)
			
			wind_terrain = enable
		}
	}
}
