/// action_tl_keyframe_deselect(timeline, keyframe)
/// @arg timeline
/// @arg keyframe

if (history_undo)
{
	with (iid_find(history_data.tl))
		tl_keyframe_select(keyframe[history_data.kf_index])
}
else
{
	var tl, kf;

	if (history_redo)
	{
		tl = iid_find(history_data.tl)
		kf = tl.keyframe[history_data.kf_index]
	}
	else
	{
		tl = argument0
		kf = argument1
		if (!kf.select)
			return 0
		
		with (history_set(action_tl_keyframe_deselect))
		{
			id.tl = iid_get(tl)
			kf_index = kf.index
		}
	}
	
	tl_keyframe_deselect(kf)
}

app_update_tl_edit()
