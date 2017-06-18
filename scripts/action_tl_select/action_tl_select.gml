/// action_tl_select(timeline)
/// @arg timeline

if (history_undo)
{
    with (history_data)
	{
        history_restore_tl_select()
        for (var t = 0; t < extend_amount; t++)
            with (iid_find(extend_tl[t]))
                tree_extend = other.extend_val[t]
    }
}
else
{
    var tl, shift, par, hobj;
    hobj = noone
    
    if (history_redo)
	{
        tl = iid_find(history_data.tl)
        shift = history_data.shift
    }
	else
	{
        tl = argument0
        shift = keyboard_check(vk_shift)
        hobj = history_set(action_tl_select)
        with (hobj)
		{
            id.tl = iid_get(tl)
            id.shift = shift
            history_save_tl_select()
            extend_amount = 0
        }
    }
    
    // Extend parents
    par = tl.parent
    while (par != app)
	{
        with (hobj)
		{
            extend_tl[extend_amount] = iid_get(par)
            extend_val[extend_amount] = par.tree_extend
            extend_amount++
        }
        par.tree_extend = true
        par = par.parent
    }
    
    // Select
    if (!shift)
        tl_deselect_all()
    with (tl)
        tl_select()
}

app_update_tl_edit()
tl_update_list()
