/// action_tl_extend(timeline)
/// @arg timeline

var tl;

if (history_undo || history_redo)
	tl = iid_find(history_data.tl)
else
{
	var hobj = history_set(action_tl_extend);
	tl = argument0
	hobj.tl = iid_get(tl)
}

tl.tree_extend=!tl.tree_extend
tl_update_list()
