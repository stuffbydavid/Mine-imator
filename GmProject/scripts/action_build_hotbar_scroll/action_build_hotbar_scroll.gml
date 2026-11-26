/// @desc Selects the previous or next hotbar.
/// @arg direction

function action_build_hotbar_scroll(direction)
{
	var list, index;
	list = build_hotbars.list
	index = mod_fix(ds_list_find_index(list.display_list, build_hotbar_current) + direction, ds_list_size(list.display_list))
	
	action_build_hotbars_list(list.display_list[|index])
	
	sortlist_view(list, list.display_list[|index], false)
	
	window_focus = string(view_main)
}
