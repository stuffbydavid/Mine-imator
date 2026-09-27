/// tl_get_visible()

function tl_get_visible()
{
	if (render_view_current = null)
		return true
	
	if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden))
		return false
	
	if (render_active = "image")
	{
		if (app.popup_exportimage.renderer = e_renderer.REALISTIC && hq_hiding)
			return false
		
		if (app.popup_exportimage.renderer != e_renderer.REALISTIC && lq_hiding)
			return false
	}
	else if (render_active = "movie")
	{
		if (app.exportmovie_renderer = e_renderer.REALISTIC && hq_hiding)
			return false
		
		if (app.exportmovie_renderer != e_renderer.REALISTIC && lq_hiding)
			return false
	}
	else if (render_view_current != null)
	{
		if (render_view_current.renderer = e_renderer.REALISTIC && hq_hiding)
			return false
		
		if (render_view_current.renderer != e_renderer.REALISTIC && lq_hiding)
			return false
	}
	
	return true
}
