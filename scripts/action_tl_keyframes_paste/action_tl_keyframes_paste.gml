/// action_tl_keyframes_paste(position)
/// @arg position

if (history_undo)
{
    with (history_data)
	{
        tl_keyframes_remove()
        history_restore_tl_select()
    }
}
else
{
    var pos;
    if (history_redo)
	{
        pos = history_data.paste_pos
        copy_kf_amount = history_data.copy_kf_amount
        copy_kf_tl = array_copy_1d(history_data.copy_kf_tl)
        copy_kf_pos = array_copy_1d(history_data.copy_kf_pos)
        copy_kf_value = array_copy_2d(history_data.copy_kf_value)
        copy_kf_tl_bodypart_of = array_copy_1d(history_data.copy_kf_tl_bodypart_of)
        copy_kf_tl_bodypart = array_copy_1d(history_data.copy_kf_tl_bodypart)
    }
	else
	{
        pos = argument0
        with (history_set(action_tl_keyframes_paste))
		{
            paste_pos = pos
            copy_kf_amount = app.copy_kf_amount
            copy_kf_tl = array_copy_1d(app.copy_kf_tl)
            copy_kf_pos = array_copy_1d(app.copy_kf_pos)
            copy_kf_value = array_copy_2d(app.copy_kf_value)
            copy_kf_tl_bodypart_of = array_copy_1d(app.copy_kf_tl_bodypart_of)
            copy_kf_tl_bodypart = array_copy_1d(app.copy_kf_tl_bodypart)
            history_save_tl_select()
        }
    }
    
    tl_keyframes_paste(pos)
}

with (obj_timeline)
    tl_update_values()
tl_update_matrix()

app_update_tl_edit()
