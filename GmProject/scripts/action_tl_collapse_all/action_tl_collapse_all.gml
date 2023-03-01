/// action_tl_collapse_all()

function action_tl_collapse_all()
{
	if (history_undo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					tree_extend = other.save_var_old_value[t]
	}
	else if (history_redo)
	{
		with (history_data)
			for (var t = 0; t < save_var_amount; t++)
				with (save_id_find(save_var_save_id[t]))
					tree_extend = other.save_var_new_value[t]
	}
	else
	{
		var hobj = history_save_var_start(action_tl_collapse_all, false);
		
		for (var t = 0; t < ds_list_size(tree_list); t++)
			with (tree_list[|t])
				action_tl_extend_children_tree(id, false, hobj)
	}
	
	tl_update_list()
}
