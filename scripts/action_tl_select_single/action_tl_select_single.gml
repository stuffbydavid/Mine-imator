/// action_tl_select_single(tl)
/// @arg timeline
/// @desc Deselects all but the given timeline. A type can also be supplied.

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
		tl = iid_find(history_data.tl)
	else
	{
		if (is_string(argument0))
		{
			with (obj_timeline)
			{
				if (type = argument0)
				{
					tl = id
					break
				}
			}
		}
		else
			tl = argument0
		
		if (!tl)
			return 0
				
		if (tl_edit_amount = 1 && tl_edit = tl)
			return 1
			
		with (history_set(action_tl_select_single))
		{
			id.tl = iid_get(tl)
			history_save_tl_select()
		}
	}
	
	with (tl)
		tl_select_single()
	
	app_update_tl_edit_select() // Don't show tabs if they're hidden
	return 1
}
