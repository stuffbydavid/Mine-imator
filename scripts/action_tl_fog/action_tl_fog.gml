/// action_tl_fog(enable)
/// @arg enable

if (history_undo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                fog = other.save_var_oldval[t]
}
else if (history_redo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                fog = other.save_var_newval[t]
}
else
{
    var hobj = history_save_var_start(action_tl_fog, false);
    
    with (obj_timeline)
	{
        if (!select)
            continue
			
        with (hobj)
            history_save_var(other.id, other.fog, argument0)
			
        fog = argument0
		
        with (obj_timeline)
		{
            if (tl_has_parent(other.id))
			{
                with (hobj)
                    history_save_var(other.id, other.fog, argument0)
					
                fog = argument0
            }
        }
    }
}
