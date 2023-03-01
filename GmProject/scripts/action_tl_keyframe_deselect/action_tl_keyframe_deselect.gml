/// action_tl_keyframe_deselect(timeline, keyframe)
/// @arg timeline
/// @arg keyframe

function action_tl_keyframe_deselect(timeline, keyframe)
{
	if (history_undo)
	{
		with (save_id_find(history_data.tl_save_id))
			tl_keyframe_select(keyframe_list[|history_data.kf_index])
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
			
			if (!kf.selected)
				return 0
			
			with (history_set(action_tl_keyframe_deselect))
			{
				tl_save_id = save_id_get(tl)
				kf_index = ds_list_find_index(tl.keyframe_list, kf)
			}
		}
		
		tl_keyframe_deselect(kf)
	}
	
	app_update_tl_edit()
}
