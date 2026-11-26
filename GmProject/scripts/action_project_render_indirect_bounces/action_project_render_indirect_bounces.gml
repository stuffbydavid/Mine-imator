function action_project_render_indirect_bounces(value, add)
{
	action_project_render_preset_edit_locked()

	var bounces = render_preset_edit.renderer[renderer_edit].indirect_bounces;

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_bounces, bounces, bounces * add + value, true)

	render_preset_edit.renderer[renderer_edit].indirect_bounces = bounces * add + value
	render_samples = -1
}
