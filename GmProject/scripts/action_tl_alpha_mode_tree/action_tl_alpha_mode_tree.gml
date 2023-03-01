/// action_tl_alpha_mode_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_alpha_mode_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.alpha_mode, nval)
	
	tl.alpha_mode = nval
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_alpha_mode_tree(tl.tree_list[|i], nval, hobj)
}
