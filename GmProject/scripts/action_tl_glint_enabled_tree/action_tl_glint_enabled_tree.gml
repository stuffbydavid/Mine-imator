/// action_tl_glint_enabled_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_glint_enabled_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.glint_enabled, nval)

	tl.glint_enabled = nval

	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_glint_enabled_tree(tl.tree_list[|i], nval, hobj)
}
