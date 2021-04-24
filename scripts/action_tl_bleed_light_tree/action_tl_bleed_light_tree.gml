/// action_tl_bleed_light_tree(timeline, newvalue, historyobject)
/// @arg timeline
/// @arg newvalue
/// @arg historyobject

function action_tl_bleed_light_tree(tl, nval, hobj)
{
	with (hobj)
		history_save_var(tl, tl.bleed_light, nval)
	
	tl.bleed_light = nval
	
	for (var i = 0; i < ds_list_size(tl.tree_list); i++)
		if (!tl.tree_list[|i].selected)
			action_tl_bleed_light_tree(tl.tree_list[|i], nval, hobj)
}
