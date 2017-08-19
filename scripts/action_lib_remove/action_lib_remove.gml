/// action_lib_remove()
/// @desc Removes the template from the library.
/// TODO

if (history_undo)
{
	with (history_data)
	{
		temp_edit = history_restore_temp(save_temp)
		history_restore_tl_select()
		
		// Restore children
		for (var c = 0; c < child_amount; c++)
			with (iid_find(child[c]))
				tl_set_parent(iid_find(other.child_parent[c]))
	}
}
else
{
	var hobj, index;
	hobj = null
	
	if (!history_redo)
	{
		hobj = history_set(action_lib_remove)
		hobj.child_amount = 0
	}
	
	// Move children of affected timelines
	with (obj_timeline)
	{
		if (temp != temp_edit || part_of != null)
			continue
		
		for (var t = 0; t < ds_list_size(tree_list); t++) // Children of own tree
		{
			with (tree_list[|t])
			{
				if (part_of != null)
					continue
					
				if (hobj)
				{
					hobj.child_save_id[hobj.child_amount] = save_id
					hobj.child_parent_save_id[hobj.child_amount] = parent.save_id
					hobj.child_amount++
				}
				tl_set_parent(other.parent, other.parent_pos)
				t--
			}
		}
		
		for (var p = 0; p < ds_list_size(part_list); p++) // Children of body parts
		{
			var part = part_list[|p];
			if (part = null)
				continue
			
			for (var t = 0; t < ds_list_size(part.tree_list); t++)
			{
				with (part.tree_list[|t])
				{
					if (part_of = null)
						continue
					
					if (hobj)
					{
						hobj.child_save_id[hobj.child_amount] = save_id
						hobj.child_parent_save_id[hobj.child_amount] = parent.save_id
						hobj.child_amount++
					}
					
					tl_set_parent(other.parent, other.parent_pos)
					t--
				}
			}
		}
	}
	
	if (!history_redo) // Backup template and selection
	{
		with (hobj)
		{
			save_temp = history_save_temp(temp_edit)
			history_save_tl_select()
		}
	}
	
	tl_deselect_all()
	
	with (temp_edit)
		instance_destroy()
}

tl_update_length()
tl_update_list()
tl_update_matrix()

app_update_tl_edit()

lib_preview.update = true
