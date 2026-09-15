/// action_tl_select_all()

function action_tl_select_all()
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
	}
	else
	{
		if (!history_redo)
			with (history_set(action_tl_select_all))
				history_save_tl_select()
		
		for (var t = 0; t < ds_list_size(tree_list); t++)
		{
			with (tree_list[|t])
			{
				if (!tl_update_list_filter(id))
					continue
				
				tl_update_recursive_select()
				tl_select()
			}
		}
	}
	
	app_update_tl_edit()
}
