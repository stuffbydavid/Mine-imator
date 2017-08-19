/// action_tl_remove()
/// @desc Removes all selected timelines.

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
	if (tl_edit = null)
		return 0
	
	if (!history_redo)
	{
		with (history_set(action_tl_remove))
		{
			tl_save_amount = 0
			history_save_tl_tree(app)
			history_save_tl_select()
		}
	}
	
	with (obj_timeline)
		if (selected && part_of = null)
			instance_destroy()
	
	tl_deselect_all()
}

tl_update_list()
tl_update_length()
tl_update_matrix()

app_update_tl_edit()
