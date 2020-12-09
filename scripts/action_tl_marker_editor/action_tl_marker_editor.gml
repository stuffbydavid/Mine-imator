/// action_tl_marker_editor(marker)
/// @arg marker

// Close context menu
context_menu_close_trigger = true

// Open 'edit marker' popup
menu_settings_set(mouse_x, mouse_y, "timelinemarkernew", 0)
settings_menu_script = marker_editor_draw
timeline_marker_edit = argument0
settings_menu_above = true
