/// action_tl_duplicate()

if (history_undo)
{
    with (obj_timeline)
        if (select && !part_of)
            instance_destroy()
		
    with (history_data)
        history_restore_tl_select()
}
else
{
    if (!tl_edit)
        return 0
        
    with (obj_timeline)
	{
        rootcopy = null
        copy = null
    }
        
    if (!history_redo) 
        with (history_set(action_tl_duplicate))
            history_save_tl_select()
    
    with (obj_timeline)
	{
        if (!select || part_of || copy || parent_is_select)
            continue
		
        tl_duplicate()
        rootcopy = copy
        with (rootcopy)
            tl_parent_root()
    }
    
    tl_deselect_all()
    
    with (obj_timeline)
	{
        with (rootcopy)
		{
            tl_select()
            tl_parent_set(other.parent)
        }
    }
}

tl_update_list()
tl_update_matrix()
app_update_tl_edit()
