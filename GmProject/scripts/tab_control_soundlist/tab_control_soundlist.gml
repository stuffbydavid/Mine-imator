/// tab_control_soundlist(soundlist)

function tab_control_soundlist(slist)
{
	var height = 46 + (ui_small_height + 2) * slist.header_show + max(soundlist_minimum_items, slist.height_items) * ui_small_height;
	tab_control(height)
}
