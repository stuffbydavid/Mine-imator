/// action_tl_path_shape_tex_mapped(mapped)
/// @arg mapped

function action_tl_path_shape_tex_mapped(mapped)
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < save_var_amount; t++)
			{
				with (save_id_find(save_var_save_id[t]))
				{
					id.path_shape_tex_mapped = other.save_var_old_value[t]
					path_update = true
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
					id.path_shape_tex_mapped = other.save_var_new_value[t]
					path_update = true
				}
			}
		}
	}
	else
	{
		var hobj = history_save_var_start(action_tl_path_shape_tex_mapped, true);
		
		with (obj_timeline)
		{
			if (!selected)
				continue
			
			with (hobj)
				history_save_var(other.id, other.path_shape_tex_mapped, mapped)
			
			id.path_shape_tex_mapped = mapped
			path_update = true
		}
	}
}