/// action_tl_parent_tree(historyobject, newparent, newposition)
/// @arg historyobject
/// @arg newparent
/// @arg newposition

var hobj, newparent, newpos;
hobj = argument0
newparent = argument1
newpos = argument2

for (var t = 0; t < tree_amount; t++)
{
	with (tree[t])
	{
		if (select && !part_of && id != newparent && !tl_has_child(newparent) && !moved)
		{
			with (hobj)
			{
				tl[tl_amount] = iid_get(other.id)
				if (other.parent = app.timeline_move_obj)
				{
					tl_old_parent[tl_amount] = iid_get(other.move_parent)
					tl_old_parent_pos[tl_amount] = other.move_parent_pos
				}
				else
				{
					tl_old_parent[tl_amount] = iid_get(other.parent)
					tl_old_parent_pos[tl_amount] = other.parent_pos
				}
				tl_old_x[tl_amount] = other.value[XPOS]
				tl_old_y[tl_amount] = other.value[YPOS]
				tl_old_z[tl_amount] = other.value[ZPOS]
				tl_amount++
			}
			
			tl_parent_set(newparent, newpos)
			moved = true
			if (keyframe_amount = 0)
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
			action_tl_parent_tree(hobj, newparent, newpos)
	}
}
