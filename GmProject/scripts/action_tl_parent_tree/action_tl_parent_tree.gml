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
					tl_old_x[tl_amount] = other.value[e_value.POS_X]
					tl_old_y[tl_amount] = other.value[e_value.POS_Y]
					tl_old_z[tl_amount] = other.value[e_value.POS_Z]
					tl_old_rot_x[tl_amount] = other.value[e_value.ROT_X]
					tl_old_rot_y[tl_amount] = other.value[e_value.ROT_Y]
					tl_old_rot_z[tl_amount] = other.value[e_value.ROT_Z]
					tl_old_sca_x[tl_amount] = other.value[e_value.SCA_X]
					tl_old_sca_y[tl_amount] = other.value[e_value.SCA_Y]
					tl_old_sca_z[tl_amount] = other.value[e_value.SCA_Z]
					tl_old_default_x[tl_amount] = other.value_default[e_value.POS_X]
					tl_old_default_y[tl_amount] = other.value_default[e_value.POS_Y]
					tl_old_default_z[tl_amount] = other.value_default[e_value.POS_Z]
					tl_old_default_rot_x[tl_amount] = other.value_default[e_value.ROT_X]
					tl_old_default_rot_y[tl_amount] = other.value_default[e_value.ROT_Y]
					tl_old_default_rot_z[tl_amount] = other.value_default[e_value.ROT_Z]
					tl_old_default_sca_x[tl_amount] = other.value_default[e_value.SCA_X]
					tl_old_default_sca_y[tl_amount] = other.value_default[e_value.SCA_Y]
					tl_old_default_sca_z[tl_amount] = other.value_default[e_value.SCA_Z]
					tl_amount++
				}
				
				tl_set_parent(newparent, newindex, true)
				
				// Lock armor
				if (type = e_tl_type.EQUIPMENT && temp != null && newparent != app && (newparent.type = e_tl_type.CHARACTER || newparent.type = e_tl_type.SPECIAL_BLOCK || newparent.type = e_tl_type.MODEL))
				{
					var model = mc_assets.model_name_map[?temp.model_name];
					if (!is_undefined(model) && model.parent_lock)
						action_tl_lock_tree(id, true, hobj)
				}
				
				moved = true
				
				t--
			}
			
			if (parent != app.timeline_move_obj)
				action_tl_parent_tree(hobj, newparent, newindex)
		}
	}
}
