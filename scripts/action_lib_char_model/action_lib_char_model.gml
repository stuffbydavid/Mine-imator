/// action_lib_char_model(model)
/// @arg model
/// @desc Changes the character model.

var model, hobj;
hobj = null

if (history_undo)
    model = history_data.oldmodel
else
{
    if (history_redo)
        model = history_data.newmodel
    else
	{
        model = argument0
        hobj = history_set(action_lib_char_model) // Save timeline info?
        with (hobj)
		{
            oldmodel = temp_edit.char_model
            newmodel = model
            tl_amount = 0
            child_amount = 0
            history_save_tl_select()
        }
    }
    
	// Find affected timelines
    with (obj_timeline)
	{
        if (temp != temp_edit || part_amount = 0)
            continue
		
        with (hobj)
            tl[tl_amount] = other.iid
		
        for (var p = 0; p < part_amount; p++)
		{
            if (!part[p])
                continue
			
            with (hobj)
                tl_old_iid[tl_amount, p] = other.part[p].iid // Save iid
			
            if (p >= model.part_amount && part[p].keyframe_amount = 0)
			{
                for (var t = 0; t < part[p].tree_amount; t++)
				{
                    with (part[p].tree[t])
					{
                        if (part_of)
                            continue
							
                        with (hobj) // Save child
						{
                            child[child_amount] = other.iid
                            child_parent[child_amount] = other.parent.iid
                            child_amount++
                        }
                        tl_parent_set(other.id)
                        t--
                    }
                }
            }
        }
        with (hobj)
            tl_amount++
    }
}

tl_deselect_all()

with (temp_edit)
{
    temp_set_char_model(model)
    if (type = "bodypart")
        temp_update_bodypart()
}

if (history_undo)
{ 
    with (history_data)
	{
        // Restore old iids
        for (var t = 0; t < tl_amount; t++) 
            with (iid_find(tl[t]))
                for (var p = 0; p < part_amount; p++)
                    if (part[p])
                        part[p].iid = history_data.tl_old_iid[t, p]
            
        // Restore children of affected part
        for (var c = 0; c < child_amount; c++) 
            with (iid_find(child[c]))
                tl_parent_set(iid_find(history_data.child_parent[c]))
                
        // Restore selection
        history_restore_tl_select()
    }
}
else if (history_redo)
{
    with (history_data) // Restore new iids
        for (var t = 0; t < tl_amount; t++)
            with (iid_find(tl[t]))
                for (var p = 0; p < part_amount; p++)
                    if (part[p])
                        part[p].iid = history_data.tl_new_iid[t, p] 
}
else
{ 
    with (hobj) // Save new iids
        for (var t = 0; t < tl_amount; t++)
            with (iid_find(tl[t]))
                for (var p = 0; p < part_amount; p++)
                    if (part[p])
                        hobj.tl_new_iid[t, p] = part[p].iid
}

app_update_tl_edit()
tl_update_list()
tl_update_matrix()

lib_preview.update = true
