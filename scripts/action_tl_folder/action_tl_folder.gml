/// action_tl_folder()

if (history_undo)
{
	with (history_data)
		with (save_id_find(spawn_save_id))
			instance_destroy()
}
else
{
	var hobj, tl;
	hobj = null
	
	if (!history_redo)
		hobj = history_set(action_tl_folder)
	
	tl = new_tl("folder")
	if (tl_edit != null)
		with (tl)
			tl_set_parent(tl_edit.parent, ds_list_find_index(tl_edit.parent.tree_list, tl_edit))
	
	if (!history_redo)
	{
		hobj.spawn_save_id = save_id_get(tl)
		if (tl_edit_amount > 0)
			action_tl_parent(tl, 0)
		
		action_tl_select(tl)
	}
}

tl_update_matrix()
tl_update_list()
