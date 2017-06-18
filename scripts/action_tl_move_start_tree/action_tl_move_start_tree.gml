/// action_tl_move_start_tree()

for (var t = 0; t < tree_amount; t++)
{
	with (tree[t])
	{
		if (select && !part_of)
		{
			move_parent = parent
			move_parent_pos = parent_pos
			tl_parent_set(app.timeline_move_obj, app.timeline_move_obj.tree_amount)
			t--
		}
		action_tl_move_start_tree()
	}
}
