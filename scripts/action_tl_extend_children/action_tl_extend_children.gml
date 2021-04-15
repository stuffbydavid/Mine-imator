/// action_tl_extend_children()

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
	var hobj = history_save_var_start(action_tl_extend_children, false);
	
	action_tl_extend_children_tree(list_item_value, true, hobj)
}

tl_update_list()
