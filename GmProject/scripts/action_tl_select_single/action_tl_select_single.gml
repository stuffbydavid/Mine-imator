/// @desc Deselects all but the given timeline.
/// @arg timeline

function action_tl_select_single(tl)
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()

		app_update_tl_edit()
	}
	else
	{
		if (history_redo)
			tl = save_id_find(history_data.tl_save_id)
		else
		{
			if (!tl)
				return false
			
			if (tl_edit_amount = 1 && tl_edit = tl)
				return true
			
			with (history_set(action_tl_select_single))
			{
				tl_save_id = save_id_get(tl)
				history_save_tl_select()
			}
		}
		
		with (tl)
			tl_select_single()
		
		app_update_tl_edit_select() // Don't show tabs if they're hidden

		return true
	}
}
