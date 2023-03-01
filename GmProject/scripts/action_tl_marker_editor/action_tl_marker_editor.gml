/// action_tl_marker_editor(marker)
/// @arg marker

function action_tl_marker_editor(marker)
{
	// Open 'edit marker' popup
	menu_settings_set(mouse_x, mouse_y, "timelinemarkernew", 0)
	settings_menu_script = marker_editor_draw
	timeline_marker_edit = marker
	settings_menu_above = true
}
