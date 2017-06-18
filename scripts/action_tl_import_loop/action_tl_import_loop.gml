/// action_tl_import_loop(filename)
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
    var fn, hobj, tladd, insertpos, goalpos;
    
    if (!history_redo)
	{
        fn = argument0
        if (!file_exists_lib(fn))
            return 0
        hobj = history_set(action_tl_import_loop)
        with (hobj)
		{
            id.fn = fn
            history_save_tl_select()
        }
    }
	else
	{
        fn = history_data.fn
        if (!file_exists_lib(fn))
            return 0
    }
    
    tladd = timeline_settings_import_loop_tl
    if (tladd.part_of)
        tladd = tladd.part_of
        
    insertpos = tladd.keyframe_select.pos
    goalpos = tladd.keyframe[tladd.keyframe_select.index + 1].pos
    
    tl_deselect_all()
    
    // Add start / end frames
    for (var p = 0; p < tladd.part_amount; p++)
	{
        with (tladd.part[p])
		{
            tl_keyframe_select(tl_keyframe_add(insertpos))
            tl_keyframe_select(tl_keyframe_add(goalpos))
        }
    }
    
    // Insert frames until next keyframe is reached
    while (insertpos < goalpos)
        insertpos = action_tl_keyframes_load_read(fn, tladd, insertpos, goalpos - insertpos)
        
    // Remove selected keyframes of root
    with (obj_keyframe)
        if (tl = tladd && select)
            tl_keyframe_remove(id)
        
    with (tladd)
	{
        tl_deselect()
        update_matrix = true
    }
    
    // Update
    project_read_update()
    
    if (!history_redo)
        with (hobj)
            history_save_loaded()
}

app_update_tl_edit()
