/// action_tl_parent(parent, position)
/// @arg parent
/// @arg position

if (history_undo)
{
    with (history_data)
	{
        for (var t = 0; t < tl_amount; t++)
		{
            with (iid_find(tl[t]))
			{
                tl_parent_set(iid_find(other.tl_old_parent[t]), other.tl_old_parent_pos[t])
                value[XPOS] = other.tl_old_x[t]
                value[YPOS] = other.tl_old_y[t]
                value[ZPOS] = other.tl_old_z[t]
            }
        }
    }
}
else
{
    var hobj, par, pos;
    hobj = null
    
    if (history_redo)
	{
        par = iid_find(history_data.newparent)
        pos = history_data.newpos
    }
	else
	{
        par = argument0
        pos = argument1
        hobj = history_set(action_tl_parent)
        hobj.newparent = iid_get(par)
        hobj.newpos = pos
        hobj.tl_amount = 0
    }
    
    with (obj_timeline)
        moved = false
    
    action_tl_parent_tree(hobj, par, pos)
    with (timeline_move_obj)
        action_tl_parent_tree(hobj, par, pos)
}

tl_update_list()
tl_update_matrix()
