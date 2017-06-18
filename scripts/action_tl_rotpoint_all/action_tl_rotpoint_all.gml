/// action_tl_rotpoint_all(point)
/// @arg point

if (history_undo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                rot_point = other.save_var_oldval[t]
}
else if (history_redo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                rot_point = other.save_var_newval[t]
}
else
{
    var hobj = history_save_var_start(action_tl_rotpoint_all, false);
    
    with (obj_timeline)
	{
        if (!select)
            continue
			
        with (hobj)
            history_save_var(other.id, other.rot_point, argument0)
			
        rot_point = argument0
    }
}
