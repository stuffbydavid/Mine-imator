/// sortlist_center(sortlist, value, [items])
/// @arg sortlist
/// @arg value
/// @arg [items]

function sortlist_center(slist, value, items = null)
{
	if (items = null)
		items = slist.visible_items
	items = max(1, items)

	var index = ds_list_find_index(slist.display_list, value);
	if (index < 0 || ds_list_size(slist.display_list) <= items)
		return false

	var firstindex = floor(slist.scroll.value / ui_small_height);
	if (index > firstindex + 1 && index < firstindex + items - 2)
		return false

	slist.scroll.value = max(0, index - floor(items / 2)) * ui_small_height
	slist.scroll.value_goal = slist.scroll.value

	return true
}
