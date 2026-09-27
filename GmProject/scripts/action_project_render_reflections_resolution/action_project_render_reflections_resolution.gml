/// action_project_render_reflections_resolution(value)
/// @arg value

function action_project_render_reflections_resolution(val)
{
	action_project_render_preset_edit_locked()

	var resolution = render_preset_edit.renderer[renderer_edit].reflections_resolution

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_resolution, resolution, val, true)

	render_preset_edit.renderer[renderer_edit].reflections_resolution = val
	render_samples = -1
}
