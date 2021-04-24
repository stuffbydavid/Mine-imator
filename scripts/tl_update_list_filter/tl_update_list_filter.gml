/// tl_update_list_filter(tl)
/// @arg tl
/// @desc Checks filters if timeline can added to visible tree list

function tl_update_list_filter(tl)
{
	// Hidden view
	if (app.setting_timeline_hide_ghosts && tl.ghost)
		return false
	
	// Doesn't match search
	if (app.timeline_search != "" && !string_contains(string_upper(tl.display_name), string_upper(app.timeline_search)))
		return false
	
	// Filtered color
	if (app.tree_update_color != null && app.timeline_hide_color_tag[app.tree_update_color])
		return false
	
	return true
}
