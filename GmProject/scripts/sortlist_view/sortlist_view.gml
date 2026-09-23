/// sortlist_view(sortlist, value, [center, [items]])
/// @arg sortlist
/// @arg value
/// @arg [center]
/// @arg [items]

function sortlist_view(slist, value, center = true, items = null)
{
	var index, firstindex;
	index = ds_list_find_index(slist.display_list, value)
	if (index < 0)
		return false

	if (center)
	{
		if (items = null)
			items = slist.items_visible
		items = max(1, items)
		if (ds_list_size(slist.display_list) <= items)
			return false

		firstindex = floor(slist.scroll.value / app.ui_small_height)
		if (index > firstindex + 1 && index < firstindex + items - 2)
			return false

		slist.scroll.value = max(0, index - floor(items / 2)) * app.ui_small_height
		slist.scroll.value_goal = slist.scroll.value
		return true
	}

	slist.view_value = value
	if (slist.view_height <= 0)
		return false

	var itemtop, itembottom, itempadding, viewtop, scrollvalue;
	itempadding = slist.header_show ? 3 : 5
	itemtop = index * ui_small_height
	itembottom = itemtop + ui_small_height + itempadding
	viewtop = slist.scroll.value_goal
	if (itemtop < viewtop)
		scrollvalue = itemtop
	else if (itembottom > viewtop + slist.view_height)
		scrollvalue = itembottom - slist.view_height
	else
		return false

	slist.scroll.value_goal = max(0, scrollvalue)
	slist.scroll.value = clamp(slist.scroll.value, slist.scroll.value_goal - list_center_max, slist.scroll.value_goal + list_center_max)
	return true
}
