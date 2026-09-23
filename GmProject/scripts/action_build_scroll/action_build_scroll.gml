/// action_build_scroll()

function action_build_scroll()
{
	var list, count, index, newindex, value;
	list = build_tool.build_list
	count = ds_list_size(list.display_list)
	if (count = 0)
		return 0

	index = ds_list_find_index(list.display_list, build_tool.build_selected)
	if (index < 0)
		index = mouse_wheel > 0 ? -1 : 0
	newindex = index + sign(mouse_wheel)
	newindex = mod_fix(newindex, count)
	value = list.display_list[|newindex]
	action_build_select(value)
	sortlist_view(list, value, false)
}
