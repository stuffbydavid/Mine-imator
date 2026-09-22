/// tl_update_list_filter(tl)
/// @arg tl
/// @desc Checks filters if timeline can added to visible tree list

function tl_update_list_filter(tl)
{
	// Currently placing
	if (tl.placed || tl.parent_is_placed)
		return false

	// Hidden view
	if (app.setting_timeline_hide_ghosts && tl.ghost)
		return false
	
	// Animated filter, can still be clicked in viewport
	if (app.setting_timeline_hide_nonanimated && !tl.animated && !(render_mode = e_render_mode.CLICK && shader_check_uniform))
		return false

	// Doesn't match search
	if (app.timeline_search != "" && !string_contains(string_upper(tl.display_name), string_upper(app.timeline_search)))
		return false
	
	// Filtered color
	if (tl.color_tag_inherit != null && app.timeline_hide_color_tag[tl.color_tag_inherit])
		return false
	
	return true
}
