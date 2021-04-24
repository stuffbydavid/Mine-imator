/// action_tl_ghost_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_ghost_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.ghost, nval)
	
	tl.ghost = nval
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		action_tl_ghost_tree(tl.tree_list[|i], nval, hobj)
}
