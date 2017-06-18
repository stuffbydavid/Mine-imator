/// action_tl_keyframes_move_done()

if (history_undo)
{
    with (history_data)
	{
        var new_index = kf_move_new_index;
        for (var k = 0; k < kf_move_amount; k++) // Move back keyframes
		{
            with (iid_find(kf_move_tl[k]).keyframe[new_index[k]])
			{
                newpos = other.kf_move_old_pos[k]
                if (pos = newpos)
                    continue
				
                with (tl)
                    tl_keyframes_pushup(other.index)
				
                for (var a = 0; a < other.kf_move_amount; a++)  // Push down other indices of same timeline
                    if (iid_find(other.kf_move_tl[a]) = tl && new_index[a] > index)
                        new_index[a]--
            }
        }
    }
}
else if (history_redo)
{
    with (history_data)
	{
        var old_index = kf_move_old_index;
        for (var k = 0; k < kf_move_amount; k++) // Move forward keyframes
		{
            with (iid_find(kf_move_tl[k]).keyframe[old_index[k]])
			{
                newpos = other.kf_move_new_pos[k]
                if (pos = newpos)
                    continue
				
                with (tl)
                    tl_keyframes_pushup(other.index)
				
                for (var a = 0; a < other.kf_move_amount; a++) // Push down other indices of same timeline
                    if (iid_find(other.kf_move_tl[a]) = tl && old_index[a] > index)
                        old_index[a]--
            }
        }
    }
}
else
{
    with (history_set(action_tl_keyframes_move_done))
	{
        kf_move_amount = 0
        with (obj_keyframe)
		{
            if (!select)
                continue
			
            other.kf_move_tl[other.kf_move_amount] = iid_get(tl)
            other.kf_move_old_index[other.kf_move_amount] = moveindex
            other.kf_move_old_pos[other.kf_move_amount] = movepos
            other.kf_move_new_index[other.kf_move_amount] = index
            other.kf_move_new_pos[other.kf_move_amount] = pos
            other.kf_move_amount++
        }
    }
    window_busy = ""
}

if (history_undo || history_redo)
{
    with (obj_keyframe) 
	{
        if (!select || pos = newpos)
            continue
        with (tl)
		{
            tl_keyframe_add(other.newpos, other.id)
            update_matrix = true
        }
    }
}

tl_update_length()
