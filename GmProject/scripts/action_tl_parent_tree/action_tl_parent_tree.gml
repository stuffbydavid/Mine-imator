/// action_tl_parent_tree(historyobject, newparent, newindex)
/// @arg historyobject
/// @arg newparent
/// @arg newindex

function action_tl_parent_tree(hobj, newparent, newindex)
{
	for (var t = 0; t < ds_list_size(tree_list); t++)
	{
		with (tree_list[|t])
		{
			if (selected && part_of = null && id != newparent && !tl_has_child(newparent) && !moved)
			{
				if (hobj != null)
				{
					hobj.tl_old_pos[hobj.tl_amount] = tl_value_get_vec3(e_value.POS_X)
					hobj.tl_old_rot[hobj.tl_amount] = tl_value_get_vec3(e_value.ROT_X)
					hobj.tl_old_sca[hobj.tl_amount] = tl_value_get_vec3(e_value.SCA_X)
					hobj.tl_old_default_pos[hobj.tl_amount] = tl_value_get_vec3(e_value.POS_X, true)
					hobj.tl_old_default_rot[hobj.tl_amount] = tl_value_get_vec3(e_value.ROT_X, true)
					hobj.tl_old_default_sca[hobj.tl_amount] = tl_value_get_vec3(e_value.SCA_X, true)
					hobj.tl_old_lock_bend[hobj.tl_amount] = lock_bend
					
					with (hobj)
					{
						tl_save_id[tl_amount] = save_id_get(other.id)
						if (other.parent = app.timeline_move_obj)
						{
							tl_old_parent_save_id[tl_amount] = save_id_get(other.move_parent)
							tl_old_parent_tree_index[tl_amount] = other.move_parent_tree_index
						}
						else
						{
							tl_old_parent_save_id[tl_amount] = save_id_get(other.parent)
							tl_old_parent_tree_index[tl_amount] = ds_list_find_index(other.parent.tree_list, other.id)
						}
						tl_amount++
					}
				}
				
				tl_set_parent(newparent, newindex, true, hobj)
				
				moved = true
				
				t--
			}
			
			if (parent != app.timeline_move_obj)
				action_tl_parent_tree(hobj, newparent, newindex)
		}
	}
}
