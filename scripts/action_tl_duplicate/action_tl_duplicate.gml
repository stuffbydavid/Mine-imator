/// action_tl_duplicate()

if (history_undo)
{
	with (obj_timeline)
		if (selected && part_of = null)
			tl_remove_clean()
	
	with (obj_timeline)
		if (delete_ready)
			instance_destroy()
	
	with (history_data)
		history_restore_tl_select()
}
else
{
	var contexttl, contextselected;
	contexttl = null
	contextselected = false
	
	with (obj_timeline)
	{
		root_copy = null
		copy = null
	}
	
	if (!history_redo)
	{
		with (history_set(action_tl_duplicate))
		{
			history_save_tl_select()
			
			if (list_item_value != null)
			{
				tl_context_save_id = list_item_value.save_id
				tl_context_selected = list_item_value.selected
			}
			else
			{
				tl_context_save_id = null
				tl_context_selected = false
			}
		}
		
		contexttl = save_id_find(history[0].tl_context_save_id)
		contextselected = history[0].tl_context_selected
	}
	else
	{
		contexttl = save_id_find(history_data.tl_context_save_id)
		contextselected = history_data.tl_context_selected
	}
	
	// Duplicate selected timelines
	if (contexttl = null || contextselected)
	{
		with (obj_timeline)
		{
			if (!selected || part_of != null || copy != null || parent_is_selected)
				continue
		
			tl_duplicate()
			root_copy = copy
			with (root_copy)
				tl_set_parent_root()
		}
	}
	else
	{
		with (contexttl)
		{
			if (part_of != null || copy != null || parent_is_selected)
				continue
		
			tl_duplicate()
			root_copy = copy
			with (root_copy)
				tl_set_parent_root()
		}
	}
	
	tl_deselect_all()
	
	with (obj_timeline)
	{
		with (root_copy)
		{
			tl_update_recursive_select()
			tl_select()
			tl_set_parent(other.parent)
		}
	}
}

tl_update_list()
tl_update_matrix()
app_update_tl_edit()
