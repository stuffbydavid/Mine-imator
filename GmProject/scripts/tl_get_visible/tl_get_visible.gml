function tl_get_visible()
{
	var renderer;

	if (render_view_current = null)
		return true
	
	if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden))
		return false
	
	if (render_active = "image")
		renderer = app.popup_exportimage.renderer
	else if (render_active = "movie")
		renderer = app.exportmovie_renderer
	else
		renderer = render_view_current.renderer
	
	return mode_visible[renderer]
}
