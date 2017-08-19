/// action_tl_extend(timeline)
/// @arg timeline

var tl;

if (history_undo || history_redo)
	tl = save_id_find(history_data.tl_save_id)
else
{
	tl = argument0
	with (history_set(action_tl_extend))
		tl_save_id = save_id_get(tl)
}

tl.tree_extend = !tl.tree_extend
tl_update_list()
