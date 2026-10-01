function view_toggle_render()
{
	if (trial_version)
	{
		popup_show(popup_upgrade)
		popup_upgrade.page = 2
		return 0
	}
	
	if (view_second.show)
	{
		if (view_second.renderer = e_renderer.REALISTIC)
		{
			view_second.renderer = e_renderer.STANDARD
			render_free()
			
			return 0
		}
		else
			view_second.renderer = e_renderer.REALISTIC
		
		if (view_main.renderer = e_renderer.REALISTIC)
			view_main.renderer = e_renderer.STANDARD
	}
	else
	{
		if (view_main.renderer = e_renderer.REALISTIC)
		{
			view_main.renderer = e_renderer.STANDARD
			render_free()
			
			return 0
		}
		else
			view_main.renderer = e_renderer.REALISTIC
	}
}
