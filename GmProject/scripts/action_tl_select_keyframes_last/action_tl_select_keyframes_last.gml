/// action_tl_select_keyframes_last()

function action_tl_select_keyframes_last()
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
	}
	else if (history_redo)
	{
		with (history_data)
			history_restore_tl_select_new()
	}
	else
	{
		var shift = keyboard_check(vk_shift);
		
		var hobj;
		hobj = history_set(action_tl_select_keyframes_last)
		
		with (hobj)
			history_save_tl_select()
		
		if (!shift)
			tl_deselect_all()
		
		with (obj_timeline)
		{
			if (lock || ds_list_size(keyframe_list) = 0 || !tl_update_list_filter(id))
				continue
			
			tl_keyframe_select(keyframe_list[|ds_list_size(keyframe_list) - 1])
		}
		
		with (hobj)
			history_save_tl_select_new()
	}
	
	app_update_tl_edit()
}
