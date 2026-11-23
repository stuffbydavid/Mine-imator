/// @desc Checks filters if the timeline can added to the visible tree list.
/// @arg timeline

function tl_update_list_filter(tl)
{
	// Currently placing
	if (tl.placed || tl.parent_is_placed)
		return false

	// Ghost timeline filter
	if (app.setting_timeline_hide_ghosts && tl.ghost)
		return false
	
	// Non-animated timeline filter (can still be clicked)
	if (render_mode != e_render_mode.CLICK || !shader_check_uniform)
	{
		if (app.setting_timeline_hide_nonanimated && !tl.animated && !tl.child_is_animated)
			return false
	}

	// Doesn't match search
	if (app.timeline_search != "" && !string_contains(string_upper(tl.display_name), string_upper(app.timeline_search)))
		return false
	
	// Filtered color
	if (tl.color_tag_inherit != null && app.timeline_hide_color_tag[tl.color_tag_inherit])
		return false
	
	return true
}
