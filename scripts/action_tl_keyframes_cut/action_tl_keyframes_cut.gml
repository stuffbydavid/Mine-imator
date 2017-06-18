/// action_tl_keyframes_cut()

if (history_undo)
{
    with (history_data)
	{
        history_restore_keyframes()
        history_restore_tl_select()
    }
}
else
{
    if (!history_redo)
	{
        with (history_set(action_tl_keyframes_cut))
		{
            history_save_keyframes()
            history_save_tl_select()
        }
        tl_keyframes_copy()
    }
    
    tl_keyframes_remove()
}

with (obj_timeline)
    tl_update_values()
tl_update_matrix()

app_update_tl_edit()
