/// view_toggle_render()

function view_toggle_render()
{
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
