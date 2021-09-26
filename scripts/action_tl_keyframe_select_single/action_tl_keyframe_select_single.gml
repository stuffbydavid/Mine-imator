/// action_tl_keyframe_select_single(timeline, keyframe)
/// @arg timeline
/// @arg keyframe

function action_tl_keyframe_select_single(timeline, keyframe)
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
	}
	else
	{
		var tl, kf;
		
		if (history_redo)
		{
			with (history_data)
			{
				tl = save_id_find(history_data.tl_save_id)
				kf = tl.keyframe_list[|history_data.kf_index]
			}
		}
		else
		{
			tl = timeline
			kf = keyframe
			
			with (history_set(action_tl_keyframe_select_single))
			{
				tl_save_id = save_id_get(tl)
				kf_index = ds_list_find_index(tl.keyframe_list, kf)
				history_save_tl_select()
			}
		}
		
		tl_deselect_all()
		tl_keyframe_select(kf)
	}
	
	app_update_tl_edit()
}
