function action_build_scroll()
{
	var picker, count, index, newindex, value;
	picker = build_tool.build_picker
	count = ds_list_size(picker.display_list)
	
	if (count = 0)
		return 0

	index = ds_list_find_index(picker.display_list, build_tool.build_selected)
	if (index < 0)
		index = mouse_wheel > 0 ? -1 : 0
	
	newindex = index + sign(mouse_wheel)
	newindex = mod_fix(newindex, count)
	value = picker.display_list[|newindex]
	
	action_build_select(value)
	
	asset_picker_view(build_tool.build_picker, value, false)
}
