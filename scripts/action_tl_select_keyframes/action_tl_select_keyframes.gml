/// action_tl_select_keyframes(timeline)
/// @arg timeline

if (history_undo)
{
	with (history_data)
		history_restore_tl_select()
}
else
{
	var tl, shift;
	
	if (history_redo)
	{
		tl = iid_find(history_data.tl)
		shift = history_data.shift
	}
	else
	{
		tl = argument0
		shift = keyboard_check(vk_shift)
		with (history_set(action_tl_select_keyframes))
		{
			id.tl = iid_get(tl)
			id.shift = shift
			history_save_tl_select()
		}
	}
	
	if (!shift)
		tl_deselect_all()
	
	with (tl)
		tl_select()
			
	for (var k = 0; k < tl.keyframe_amount; k++)
	{
		if (tl.keyframe[k].select)
			continue
		tl_keyframe_select(tl.keyframe[k])
	}
}

app_update_tl_edit()
