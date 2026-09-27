/// window_event_closed(window)
/// Runs when a window is closed.

function window_event_closed(window)
{
	if (window_debug_current = window)
		window_debug_current = e_window.MAIN
	
	if (tip_window = window)
		tip_reset()

	if (window = e_window.VIEW_SECOND)
		app.view_second.show = false
	if (window = e_window.TIMELINE)
		panel_tab_list_add(app.timeline.panel_last, 0, app.timeline)
	
	ds_list_delete_value(window_list, window)
}