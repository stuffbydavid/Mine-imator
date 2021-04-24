/// action_tl_depth_tree(timeline, newvalue, add, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg add
/// @arg historyobject

function action_tl_depth_tree(tl, nval, add, hobj)
{
	with (hobj)
		history_save_var(tl, tl.depth, tl.depth * add + nval)
	
	tl.depth = tl.depth * add + nval
	with (tl)
		tl_update_depth()
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_depth_tree(tl.tree_list[|i], nval, add, hobj)
}
