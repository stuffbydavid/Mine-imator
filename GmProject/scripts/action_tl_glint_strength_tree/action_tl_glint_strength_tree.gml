/// action_tl_glint_strength_tree(timeline, newvalue, add, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg add
/// @arg historyobject

function action_tl_glint_strength_tree(tl, nval, add, hobj)
{
	with (hobj)
		history_save_var(tl, tl.glint_strength, tl.glint_strength * add + nval / 100)
	
	tl.glint_strength = tl.glint_strength * add + nval / 100
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_glint_strength_tree(tl.tree_list[|i], nval, add, hobj)
}
