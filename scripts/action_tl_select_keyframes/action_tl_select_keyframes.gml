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
		tl = save_id_find(history_data.tl_save_id)
		shift = history_data.shift
	}
	else
	{
		tl = argument0
		shift = keyboard_check(vk_shift)
		with (history_set(action_tl_select_keyframes))
		{
			tl_save_id = save_id_get(tl)
			id.shift = shift
			history_save_tl_select()
		}
	}
	
	if (!shift)
		tl_deselect_all()
	
	with (tl)
		tl_select()
	
	for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
		tl_keyframe_select(tl.keyframe_list[|k])
}

app_update_tl_edit()
