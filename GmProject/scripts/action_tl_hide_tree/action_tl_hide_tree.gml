/// action_tl_hide_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_hide_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.hide, nval)
	
	tl.hide = nval
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		action_tl_hide_tree(tl.tree_list[|i], nval, hobj)
}
