/// action_tl_search(search)
/// @arg search

var search;

if (history_undo)
	search = history_data.old_value
else if (history_redo)
	search = history_data.new_value
else
{
	search = argument0
	history_set_var(action_tl_search, timeline_search, search, true)
}

timeline_search = search
tl_update_list()
