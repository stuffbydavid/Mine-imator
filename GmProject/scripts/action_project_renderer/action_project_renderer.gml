/// action_project_renderer(renderer)
/// @arg renderer

function action_project_renderer(renderer)
{
	// Need "Full" version to customize Realistic renderer
	if (renderer = e_renderer.REALISTIC && trial_version)
	{
		popup_show(popup_upgrade)
		popup_upgrade.page = 2
		return 0
	}
		
	tab.render.renderer = renderer
	renderer_edit = renderer
}