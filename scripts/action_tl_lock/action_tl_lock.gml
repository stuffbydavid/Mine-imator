/// action_tl_lock(timeline)
/// @arg timeline

if (history_undo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                lock = other.save_var_oldval[t]
}
else if (history_redo)
{
    with (history_data)
        for (var t = 0; t < save_var_amount; t++)
            with (iid_find(save_var_obj[t]))
                lock = other.save_var_newval[t]
}
else
{
    var hobj = history_save_var_start(action_tl_lock, false);
    
    with (argument0)
	{
        with (hobj)
            history_save_var(other.id, other.lock, !other.lock)
			
        lock=!lock
		
        with (obj_timeline)
		{
            if (tl_has_parent(other.id))
			{
                with (hobj)
                    history_save_var(other.id, other.lock, argument0.lock)
					
                lock = argument0.lock
            }
        }
    }
}
