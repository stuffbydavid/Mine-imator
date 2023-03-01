/// action_tl_path_smooth_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_path_smooth_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.path_smooth, nval)
	
	tl.path_smooth = nval
	with (tl)
		path_update = true
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_path_smooth_tree(tl.tree_list[|i], nval, hobj)
}
