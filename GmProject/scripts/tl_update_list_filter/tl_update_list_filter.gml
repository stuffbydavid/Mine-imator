/// tl_update_list_filter(tl)
/// @arg tl
/// @desc Checks filters if timeline can added to visible tree list

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
		var parentstructure = (tl.parent != null && tl.parent.object_index = obj_timeline && type_is_structure(tl.parent.type));
		if (!tl.animated && !tl.child_is_animated &&
			(app.setting_timeline_hide_nonanimated ||
			 (app.setting_timeline_hide_structure_blocks && tl.type = e_tl_type.BLOCK && parentstructure)))
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
