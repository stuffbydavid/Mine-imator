/// action_tl_remove()
/// @desc Removes all selected timelines.

function action_tl_remove()
{
	if (history_undo)
	{
		with (history_data)
		{
			for (var t = 0; t < tl_save_amount; t++)
				history_restore_tl(tl_save_obj[t])
			history_restore_tl_select()
		}
	}
	else
	{
		var contexttl = null;
		
		if (!history_redo)
		{
			with (history_set(action_tl_remove))
			{
				tl_save_amount = 0
				history_save_tl_select()
				tl_context_save_id = (list_item_value = null ? null : list_item_value.save_id)
				
				// "Select" right-clicked object for removal
				if (list_item_value != null && !list_item_value.selected)
				{
					with (list_item_value)
						tl_select_single()
				}
				
				history_save_tl_tree(app)
				history_restore_tl_select()
			}
			
			contexttl = save_id_find(history[0].tl_context_save_id)
		}
		else
			contexttl = save_id_find(history_data.tl_context_save_id)
		
		// Get timelines ready for deletion
		if (contexttl = null || contexttl.selected)
		{
			with (obj_timeline)
				if (selected && part_of = null && !delete_ready)
					tl_remove_clean()
			
			tl_deselect_all()
		}
		else
		{
			with (contexttl)
				if (part_of = null && !delete_ready)
					tl_remove_clean()
		}
		
		with (obj_timeline)
			if (delete_ready)
				instance_destroy()
	}
	
	project_ik_part_array = null
	
	tl_update_list()
	tl_update_length()
	tl_update_matrix()
	
	app_update_tl_edit()
}
