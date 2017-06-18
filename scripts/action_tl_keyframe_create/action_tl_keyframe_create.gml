/// action_tl_keyframe_create(timeline, position)
/// @arg timeline
/// @arg position

if (history_undo)
{
    with (history_data)
        history_restore_tl_select()

    with (iid_find(history_data.tl))
	{
        tl_keyframe_remove(keyframe[history_data.kf_index])
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
        tl = iid_find(history_data.tl)
        pos = history_data.pos
    }
	else
	{
        tl = argument0
        pos = argument1
        hobj = history_set(action_tl_keyframe_create)
        with (hobj)
		{
            id.tl = iid_get(tl)
            id.pos = pos
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
        hobj.kf_index = kf.index
}

app_update_tl_edit()
