/// action_tl_keyframes_remove()
/// @desc Removes selected keyframes.

function action_tl_keyframes_remove()
{
	if (history_undo)
	{
		with (history_data)
		{
			history_restore_keyframes()
			history_restore_tl_select()
		}
	}
	else
	{
		if (!history_redo)
		{
			with (history_set(action_tl_keyframes_remove))
			{
				history_save_keyframes()
				history_save_tl_select()
			}
		}
		
		tl_keyframes_remove()
	}
	
	with (obj_timeline)
	{
		tl_update_values()
		
		// Force bend cache to be cleared
		if (model_part != null)
			model_clear_bend_cache = true
	}
	
	tl_update_matrix()
	tl_update_length()
	
	app_update_tl_edit()
}
