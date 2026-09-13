/// action_project_render_shadows_sun_cascades(value, add)
/// @arg value
/// @arg add

function action_project_render_shadows_sun_cascades(val, add)
{
	action_project_render_preset_edit_locked()

	var cascades = render_preset_edit.renderer[renderer_edit].shadows_sun_cascades
	var newcascades = clamp(round(cascades * add + val), 1, 3)

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_sun_cascades, cascades, newcascades, true)

	render_preset_edit.renderer[renderer_edit].shadows_sun_cascades = newcascades
	project_render_shadows_sun_cascades = newcascades
	render_cascades_count = newcascades
	render_samples = -1
}
