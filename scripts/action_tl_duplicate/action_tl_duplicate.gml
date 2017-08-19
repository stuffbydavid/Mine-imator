/// action_tl_duplicate()

if (history_undo)
{
	with (obj_timeline)
		if (selected && part_of = null)
			instance_destroy()
		
	with (history_data)
		history_restore_tl_select()
}
else
{
	if (tl_edit = null)
		return 0
		
	with (obj_timeline)
	{
		root_copy = null
		copy = null
	}
		
	if (!history_redo) 
		with (history_set(action_tl_duplicate))
			history_save_tl_select()
	
	with (obj_timeline)
	{
		if (!selected || part_of != null || copy != null || parent_is_selected)
			continue
		
		tl_duplicate()
		root_copy = copy
		with (root_copy)
			tl_parent_root()
	}
	
	tl_deselect_all()
	
	with (obj_timeline)
	{
		with (root_copy)
		{
			tl_select()
			tl_parent_set(other.parent)
		}
	}
}

tl_update_list()
tl_update_matrix()
app_update_tl_edit()
