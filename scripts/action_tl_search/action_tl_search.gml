/// action_tl_search(search)
/// @arg search

function action_tl_search(search)
{
	if (!history_undo && !history_redo)
		history_set_var(action_tl_search, timeline_search, search, true)
	
	timeline_search = search
	tl_update_list()
}
