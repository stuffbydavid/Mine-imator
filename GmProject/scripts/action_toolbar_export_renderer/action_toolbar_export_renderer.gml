/// action_toolbar_export_renderer(renderer)
/// @arg renderer

function action_toolbar_export_renderer(renderer)
{
	if (renderer = e_renderer.REALISTIC && trial_version)
	{
		popup_switch(popup_upgrade)
		popup_upgrade.page = 2
		return false
	}

	popup.renderer = renderer
	return true
}
