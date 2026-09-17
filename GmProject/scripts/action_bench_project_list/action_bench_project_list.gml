/// action_bench_project_list(list)

function action_bench_project_list(list)
{
	var selected;
	selected = bench_settings.project_selected
	bench_settings.project_list = list
	window_scroll_focus = string(list.scroll)
	
	if (ds_list_find_index(list.list, selected) < 0)
		selected = null
	else
		sortlist_center(list, selected)
	
	action_bench_project_select(selected)
}
