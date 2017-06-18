/// action_tl_folder()

if (history_undo)
{
	with (history_data)
		with (iid_find(spawn))
			instance_destroy()
}
else
{
	var hobj, tl;
	hobj = null
	
	if (!history_redo)
		hobj = history_set(action_tl_folder)
	
	tl = new_tl("folder")
	if (tl_edit)
		with (tl)
			tl_parent_set(tl_edit.parent, tl_edit.parent_pos)
	
	if (!history_redo)
	{
		hobj.spawn = iid_get(tl)
		if (tl_edit_amount > 0)
			action_tl_parent(tl, 0)
		action_tl_select(tl)
	}
}

tl_update_matrix()
tl_update_list()
