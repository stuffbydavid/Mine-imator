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
				
				var reset = false;
				
				// Reset and lock armor
				if (type = e_tl_type.EQUIPMENT && temp != null && newparent != app &&
				    (newparent.type = e_tl_type.CHARACTER || newparent.type = e_tl_type.SPECIAL_BLOCK || newparent.type = e_tl_type.MODEL))
				{
					reset = true
					
					var model = mc_assets.model_name_map[?temp.model_name];
					if (!is_undefined(model) && model.parent_lock)
						action_tl_lock_tree(id, true, hobj)
				}

				tl_set_parent(newparent, newindex, !reset)
				if (reset)
				{
					tl_value_set_vec3(e_value.POS_X, vec3(0))
					tl_value_set_vec3(e_value.ROT_X, vec3(0))
					tl_value_set_vec3(e_value.SCA_X, vec3(1))
					tl_value_set_vec3(e_value.POS_X, vec3(0), true)
					tl_value_set_vec3(e_value.ROT_X, vec3(0), true)
					tl_value_set_vec3(e_value.SCA_X, vec3(1), true)
				}
				
				moved = true
				
				t--
			}
			
			if (parent != app.timeline_move_obj)
				action_tl_parent_tree(hobj, newparent, newindex)
		}
	}
}
