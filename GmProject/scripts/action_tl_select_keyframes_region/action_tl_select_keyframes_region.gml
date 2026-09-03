/// action_tl_select_keyframes_region()

function action_tl_select_keyframes_region()
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
		hobj = history_set(action_tl_select_keyframes_region)
		
		with (hobj)
			history_save_tl_select()
		
		if (!shift)
			tl_deselect_all()
		
		with (obj_keyframe)
		{
			if (timeline.lock || !tl_update_list_filter(timeline))
				continue
			
			if (position >= app.timeline_region_start && position <= app.timeline_region_end)
				tl_keyframe_select(id)
		}
		
		with (hobj)
			history_save_tl_select_new()
	}
	
	app_update_tl_edit()
}
