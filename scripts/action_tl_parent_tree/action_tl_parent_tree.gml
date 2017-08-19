/// action_tl_parent_tree(historyobject, newparent, newindex)
/// @arg historyobject
/// @arg newparent
/// @arg newindex

var hobj, newparent, newindex;
hobj = argument0
newparent = argument1
newindex = argument2

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
					tl_old_parent_index[tl_amount] = other.move_parent_index
				}
				else
				{
					tl_old_parent_save_id[tl_amount] = save_id_get(other.parent)
					tl_old_parent_index[tl_amount] = ds_list_find_index(other.parent.tree_list, other.id)
				}
				tl_old_x[tl_amount] = other.value[XPOS]
				tl_old_y[tl_amount] = other.value[YPOS]
				tl_old_z[tl_amount] = other.value[ZPOS]
				tl_amount++
			}
			
			tl_parent_set(newparent, newindex)
			moved = true
			if (ds_list_size(keyframe_list) = 0)
			{
				if (parent = app)
				{
					value[XPOS] = value_default[XPOS]
					value[YPOS] = value_default[YPOS]
					value[ZPOS] = value_default[ZPOS]
				}
				else
				{
					value[XPOS] = 0
					value[YPOS] = 0
					value[ZPOS] = 0
				}
			}
			t--
		}
		
		if (parent != app.timeline_move_obj)
			action_tl_parent_tree(hobj, newparent, newindex)
	}
}
