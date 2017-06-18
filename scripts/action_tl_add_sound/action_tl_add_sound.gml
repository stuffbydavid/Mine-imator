/// action_tl_add_sound()

if (history_undo)
{
    with (tl_edit)
	{
        tl_keyframe_remove(keyframe[history_data.kf_index])
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
        fn = history_data.fn
        pos = history_data.pos
    }
	else
	{
        fn = file_dialog_open_sound()
        if (!file_exists_lib(fn))
            return 0
        pos = timeline_marker
        hobj = history_set(action_new_tl_sound)
    }
    
    res = new_res("sound", fn)
    res.loaded=!res.replaced
    with (res)
        res_load()
        
    with (tl_edit)
	{
        kf = tl_keyframe_add(pos)
        kf.value[SOUNDOBJ] = res
        res.count++
        tl_update_values()
    }
    
    if (!history_redo)
	{
        with (hobj)
		{
            id.fn = fn
            id.pos = pos
            id.kf_index = kf.index
            history_save_loaded()
        }
    }
}

project_reset_loaded()
tl_update_length()
