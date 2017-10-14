/// action_tl_add_sound()

if (history_undo)
{
	with (tl_edit)
	{
		with (keyframe_list[|history_data.kf_index])
			instance_destroy()
		tl_update_values()
	}
	with (history_data)
		history_destroy_loaded()
}
else
{
	var fn, pos, res, kf, hobj;
	
	if (history_redo)
	{
		fn = history_data.filename
		pos = history_data.position
	}
	else
	{
		fn = file_dialog_open_sound()
		if (!file_exists_lib(fn))
			return 0
		pos = timeline_marker
		hobj = history_set(action_tl_add_sound)
	}
	
	res = new_res(fn, e_res_type.SOUND)
	res.loaded = !res.replaced
	with (res)
		res_load()
		
	with (tl_edit)
	{
		kf = tl_keyframe_add(pos)
		kf.value[e_value.SOUND_OBJ] = res
		res.count++
		tl_update_values()
	}
	
	if (!history_redo)
	{
		with (hobj)
		{
			filename = fn
			position = pos
			kf_index = ds_list_find_index(tl_edit.keyframe_list, kf)
			history_save_loaded()
		}
	}
}

project_reset_loaded()
tl_update_length()
