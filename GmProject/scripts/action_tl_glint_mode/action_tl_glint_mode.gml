/// action_tl_glint_mode(mode)
/// @arg mode

function action_tl_glint_mode(mode)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glint_mode = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glint_mode = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_glint_mode, false);
		with (obj_timeline)
			if (selected)
				action_tl_glint_mode_tree(id, mode, hobj)
	}
}
