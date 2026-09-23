/// tab_control_sortlist(sortlist)
/// @arg sortlist

function tab_control_sortlist(slist)
{
	var height = 46 + (ui_small_height + 2) * slist.header_show + max(list_minimum_items, slist.height_items) * ui_small_height;
	tab_control(height)
}
