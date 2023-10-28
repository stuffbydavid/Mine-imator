/// action_tl_glint_strength(value, add)
/// @arg value
/// @arg add

function action_tl_glint_strength(val, add)
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glint_strength = other.save_var_old_value[t]

	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					glint_strength = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_glint_strength, true);
		
		with (obj_timeline)
			if (selected)
				action_tl_glint_strength_tree(id, val, add, hobj)
	}
}
