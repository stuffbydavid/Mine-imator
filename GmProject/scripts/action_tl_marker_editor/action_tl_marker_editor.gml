function action_tl_marker_editor(marker)
{
	// Open "Edit marker" popup
	menu_settings_set(mouse_x, mouse_y, "timelinemarkernew", 0)
	
	timeline_marker_edit = marker
	settings_menu_script = marker_editor_draw
	settings_menu_above = true
}
