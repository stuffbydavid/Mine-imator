/// action_tl_backfaces(enable)
/// @arg enable

if (history_undo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (save_id_find(save_var_save_id[t]))
				backfaces = other.save_var_old_value[t]
}
else if (history_redo)
{
	with (history_data)
		for (var t = 0; t < save_var_amount; t++)
			with (save_id_find(save_var_save_id[t]))
				backfaces = other.save_var_new_value[t]
}
else
{
	var hobj = history_save_var_start(action_tl_backfaces, false);
	
	with (obj_timeline)
		if (selected)
			action_tl_backfaces_tree(id, argument0, hobj)
}
