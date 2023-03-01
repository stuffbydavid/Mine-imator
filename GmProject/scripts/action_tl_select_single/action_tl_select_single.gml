/// action_tl_select_single(tl, [type])
/// @arg timeline
/// @arg [type]
/// @desc Deselects all but the given timeline. A type can also be supplied.

function action_tl_select_single()
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
		
		app_update_tl_edit()
	}
	else
	{
		var tl = null;
		
		if (history_redo)
			tl = save_id_find(history_data.tl_save_id)
		else
		{
			if (argument_count > 1 && argument[1] != null)
			{
				with (obj_timeline)
				{
					if (type = argument[1])
					{
						tl = id
						break
					}
				}
			}
			else
				tl = argument[0]
			
			if (!tl)
				return 0
			
			if (tl_edit_amount = 1 && tl_edit = tl)
				return 1
			
			with (history_set(action_tl_select_single))
			{
				tl_save_id = save_id_get(tl)
				history_save_tl_select()
			}
		}
		
		with (tl)
			tl_select_single()
		
		app_update_tl_edit_select() // Don't show tabs if they're hidden
		return 1
	}
}
