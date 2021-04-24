/// action_tl_glow_texture(enable)
/// @arg enable

function action_tl_glow_texture(enable)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glow_texture = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glow_texture = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_glow_texture, false);
		
		with (obj_timeline)
			if (selected)
				action_tl_glow_texture_tree(id, enable, hobj)
	}
}
