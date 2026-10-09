function action_toolbar_export_renderer(renderer)
{
	if (renderer = e_renderer.REALISTIC && trial_version)
	{
		popup_switch(popup_upgrade)
		popup_upgrade.page = 2
		return 0
	}

	popup_current.renderer = renderer
}
