/// action_tl_load_loop(filename)
/// @arg filename

if (history_undo)
{
	tl_keyframes_remove()
	with (history_data)
	{
		history_destroy_loaded()
		history_restore_tl_select()
	}
		
	tl_update_list()
	with (obj_timeline)
		tl_update_values()
	tl_update_matrix()
}
else
{
	var fn, hobj;
	hobj = null
	
	if (!history_redo)
	{
		fn = argument0
		if (!file_exists_lib(fn))
			return 0
		
		hobj = history_set(action_tl_load_loop)
		with (hobj)
		{
			filename = fn
			history_save_tl_select()
		}
	}
	else
	{
		fn = history_data.filename
		if (!file_exists_lib(fn))
			return 0
	}
	
	var tladd = timeline_settings_import_loop_tl;
	if (tladd.part_of != null)
		tladd = tladd.part_of
		
	var insertpos, goalpos;
	insertpos = tladd.keyframe_select.position
	goalpos = tladd.keyframe_list[|ds_list_find_index(tladd.keyframe_list, tladd.keyframe_select) + 1].position
	
	tl_deselect_all()
	
	// Add start/end frames
	for (var p = 0; p < ds_list_size(tladd.part_list); p++)
	{
		with (tladd.part_list[|p])
		{
			tl_keyframe_select(tl_keyframe_add(insertpos))
			tl_keyframe_select(tl_keyframe_add(goalpos))
		}
	}
	
	// Insert frames until next keyframe is reached
	while (insertpos < goalpos)
		insertpos = action_tl_keyframes_load_file(fn, tladd, insertpos, goalpos - insertpos)
		
	// Remove selected keyframes of root
	with (obj_keyframe)
		if (timeline = tladd && selected)
			instance_destroy()
		
	with (tladd)
	{
		tl_deselect()
		update_matrix = true
	}
	
	// Update
	project_load_update()
	
	with (hobj)
		history_save_loaded()
}

app_update_tl_edit()
