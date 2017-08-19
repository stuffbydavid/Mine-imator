/// action_tl_move_start_tree()

for (var t = 0; t < ds_list_size(tree_list); t++)
{
	with (tree_list[|t])
	{
		if (selected && part_of = null)
		{
			move_parent = parent
			move_parent_index = ds_list_find_index(parent.tree_list, id)
			tl_parent_set(app.timeline_move_obj)
			t--
		}
		action_tl_move_start_tree()
	}
}
