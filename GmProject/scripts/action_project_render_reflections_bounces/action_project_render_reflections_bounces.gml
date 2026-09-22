/// action_project_render_reflections_bounces(value, add)
/// @arg value
/// @arg add

function action_project_render_reflections_bounces(val, add)
{
	action_project_render_preset_edit_locked()

	var bounces = render_preset_edit.renderer[renderer_edit].reflections_bounces

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_reflections_bounces, bounces, bounces * add + val, true)

	render_preset_edit.renderer[renderer_edit].reflections_bounces = bounces * add + val
	render_samples = -1
}
