/// tl_jump(tl)
/// @arg tl

function tl_jump(tl)
{
	// Use the nearest visible parent for filtered timelines
	var pos = ds_list_find_index(tree_visible_list, tl);
	while (pos < 0 && tl.parent_filter != app)
	{
		tl = tl.parent_filter
		pos = ds_list_find_index(tree_visible_list, tl)
	}

	if (pos < 0)
		return 0
	
	if (pos < timeline_list_first || pos >= timeline_list_first + timeline_list_visible)
	{
		// Set scrollbar
		var newval = pos - floor(timeline_list_visible / 2);
		newval = min(newval, ds_list_size(tree_visible_list) - timeline_list_visible)
		newval = max(0, newval)
		timeline.ver_scroll.value_goal = newval * timeline.ver_scroll.snap_value
	}
}
