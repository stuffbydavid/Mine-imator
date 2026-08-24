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
					tl_amount++
				}
				
				tl_set_parent(newparent, newindex)
				moved = true
				
				// Parented objects with no keyframes get position reset
				if (ds_list_size(keyframe_list) = 0)
				{
					if (parent = app)
					{
						value[e_value.POS_X] = value_default[e_value.POS_X]
						value[e_value.POS_Y] = value_default[e_value.POS_Y]
						value[e_value.POS_Z] = value_default[e_value.POS_Z]
					}
					else
					{
						value[e_value.POS_X] = 0
						value[e_value.POS_Y] = 0
						value[e_value.POS_Z] = 0
					}
				}
				t--
			}
			
			if (parent != app.timeline_move_obj)
				action_tl_parent_tree(hobj, newparent, newindex)
		}
	}
}
