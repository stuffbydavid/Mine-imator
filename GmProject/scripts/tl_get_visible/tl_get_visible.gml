/// tl_get_visible()

function tl_get_visible()
{
	if (render_view_current = null)
		return true
	
	if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden))
		return false
	
	if (render_active = "image")
	{
		if (app.popup_exportimage.high_quality && hq_hiding)
			return false
		
		if (!app.popup_exportimage.high_quality && lq_hiding)
			return false
	}
	else if (render_active = "movie")
	{
		if (app.exportmovie_high_quality && hq_hiding)
			return false
		
		if (!app.exportmovie_high_quality && lq_hiding)
			return false
	}
	else if (render_view_current != null)
	{
		if (render_view_current.quality = e_view_mode.RENDER && hq_hiding)
			return false
		
		if (render_view_current.quality != e_view_mode.RENDER && lq_hiding)
			return false
	}
	
	return true
}
