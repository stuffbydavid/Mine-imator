/// action_tl_keyframes_load(filename)
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
	var fn, insertpos, hobj, tladd;
	
	if (history_redo)
	{
		fn = history_data.fn
		insertpos = history_data.insertpos
		
		if (!file_exists_lib(fn))
			return 0
	}
	else
	{
		fn = argument0
		
		if (!file_exists_lib(fn))
			return 0
			
		if (!tl_edit)
		{
			error("erroropenkeyframes")
			return 0
		}
		
		insertpos = timeline_insert_pos
		hobj = history_set(action_tl_keyframes_load)
		with (hobj)
		{
			id.fn = fn
			id.insertpos = insertpos
			history_save_tl_select()
		}
	}
	
	tladd = tl_edit
	tl_deselect_all()
		
	// Read file
	action_tl_keyframes_load_read(fn, tladd, insertpos, null)
	
	// Update
	project_read_update()
		
	if (!history_redo)
		with (hobj)
			history_save_loaded()
}

app_update_tl_edit()
