/// tl_jump(tl)
/// @arg tl

function tl_jump(tl)
{
	// Find pos
	var pos;
	for (pos = 0; pos < ds_list_size(tree_visible_list); pos++)
		if (tree_visible_list[|pos] = tl)
			break
	
	if (pos < timeline_list_first || pos >= timeline_list_first + timeline_list_visible)
	{
		// Set scrollbar
		var newval = pos - floor(timeline_list_visible / 2);
		newval = min(newval, ds_list_size(tree_visible_list) - timeline_list_visible)
		newval = max(0, newval)
		timeline.ver_scroll.value_goal = newval * timeline.ver_scroll.snap_value
	}
}