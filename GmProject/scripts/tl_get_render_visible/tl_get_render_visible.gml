function tl_get_render_visible()
{
	// Invisible setting
	if (!value_inherit[e_value.VISIBLE] || (hide && !render_hidden))
		return false
	
	// No valid 3D model
	if (!type_is_visible(type))
		return false
	
	if (type = e_tl_type.MODEL && (temp.model = null || temp.model.model_format = e_model_format.MIMODEL))
		return false

	if (type = e_tl_type.STRUCTURE && array_length(blocks_added) = 0)
		return false
	
	if (type = e_tl_type.PARTICLE_SPAWNER && !render_particles)
		return false
	
	// Currently placed
	if (!app.place_tl_render && (placed || parent_is_placed))
		return false
	
	// Mode visibility
	if (render_active = "image")
		return mode_visible[app.popup_exportimage.renderer]
	else if (render_active = "movie")
		return mode_visible[app.exportmovie_renderer]
	else if (render_view_current != null)
		return mode_visible[render_view_current.renderer]
	
	return true
}
