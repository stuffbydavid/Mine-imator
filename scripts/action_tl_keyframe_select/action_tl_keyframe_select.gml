/// action_tl_keyframe_select(timeline, keyframe)
/// @arg timeline
/// @arg keyframe

function action_tl_keyframe_select(timeline, keyframe)
{
	if (history_undo)
	{
		with (save_id_find(history_data.tl_save_id))
			tl_keyframe_deselect(keyframe_list[|history_data.kf_index])
	}
	else
	{
		var tl, kf;
		
		if (history_redo)
		{
			tl = save_id_find(history_data.tl_save_id)
			kf = tl.keyframe_list[|history_data.kf_index]
		}
		else
		{
			tl = timeline
			kf = keyframe
			
			if (kf.selected)
				return 0
			
			with (history_set(action_tl_keyframe_select))
			{
				tl_save_id = save_id_get(tl)
				kf_index = ds_list_find_index(tl.keyframe_list, kf)
			}
		}
		
		tl_keyframe_select(kf)
	}
	
	app_update_tl_edit()
}
