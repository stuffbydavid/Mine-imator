function action_project_render_indirect_resolution(value)
{
	action_project_render_preset_edit_locked()

	var resolution = render_preset_edit.renderer[renderer_edit].indirect_resolution;

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_indirect_resolution, resolution, value, true)

	render_preset_edit.renderer[renderer_edit].indirect_resolution = value
	render_samples = -1
}
