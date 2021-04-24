/// action_tl_keyframe_create(timeline, position)
/// @arg timeline
/// @arg position

function action_tl_keyframe_create(timeline, position)
{
	if (history_undo)
	{
		with (history_data)
			history_restore_tl_select()
		
		with (save_id_find(history_data.tl_save_id))
		{
			with (keyframe_list[|history_data.kf_index])
				instance_destroy()
			tl_update_values()
			update_matrix = true
			tl_update_matrix()
		}
	}
	else
	{
		var tl, pos, kf, hobj;
		
		if (history_redo)
		{
			tl = save_id_find(history_data.tl_save_id)
			pos = history_data.position
		}
		else
		{
			tl = timeline
			pos = position
			hobj = history_set(action_tl_keyframe_create)
			with (hobj)
			{
				id.tl_save_id = save_id_get(tl)
				id.position = pos
				history_save_tl_select()
			}
		}
		
		tl_deselect_all()
		
		with (tl)
		{
			tl_select()
			kf = tl_keyframe_add(pos)
			update_matrix = true
			tl_update_matrix()
		}
		
		if (!history_redo)
			hobj.kf_index = ds_list_find_index(tl.keyframe_list, kf)
	}
	
	app_update_tl_edit()
	tl_update_length()
}
