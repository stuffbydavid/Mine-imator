/// @desc Selects a hotbar from the list.
/// @arg hotbar

function action_build_hotbars_list(hotbar)
{
	if (hotbar = null)
		return 0

	var index = ds_list_find_index(build_hotbars.list.list, hotbar);
	if (index < 0)
		return 0

	build_hotbars.selected = index
	build_hotbar_current = hotbar
	build_hotbar_slot = clamp(build_hotbar_slot, 0, max(0, array_length(hotbar.blocks) - 1))
	
	if (place_build && array_length(hotbar.blocks) > 0)
	{
		action_build_hotbar_select(build_hotbar_slot)
		window_focus = string(build_hotbars.list.scroll)
	}
}
