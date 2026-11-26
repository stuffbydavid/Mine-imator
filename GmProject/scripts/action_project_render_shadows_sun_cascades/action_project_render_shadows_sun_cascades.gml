function action_project_render_shadows_sun_cascades(value, add)
{
	action_project_render_preset_edit_locked()

	var cascades, newcascades;
	cascades = render_preset_edit.renderer[renderer_edit].shadows_sun_cascades
	newcascades = clamp(round(cascades * add + value), 1, 3)

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_sun_cascades, cascades, newcascades, true)

	render_preset_edit.renderer[renderer_edit].shadows_sun_cascades = newcascades
	project_render_shadows_sun_cascades = newcascades
	render_cascades_count = newcascades
	render_samples = -1
}
