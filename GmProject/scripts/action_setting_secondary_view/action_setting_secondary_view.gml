/// action_setting_secondary_view()

function action_setting_secondary_view()
{
	view_second.show = !view_second.show
	
	if (!view_second.show)
		window_close(e_window.VIEW_SECOND)
	else
		view_second.location = view_second.location_last
}
