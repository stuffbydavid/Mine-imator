/// action_project_render_shadows_sun_cascades(value, add)
/// @arg value
/// @arg add

function action_project_render_shadows_sun_cascades(val, add)
{
	action_project_render_preset_edit_locked()

	var cascades = render_preset_edit.renderer[renderer_edit].shadows_sun_cascades

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_sun_cascades, cascades, cascades * add + val, true)

	render_preset_edit.renderer[renderer_edit].shadows_sun_cascades = cascades * add + val
}
