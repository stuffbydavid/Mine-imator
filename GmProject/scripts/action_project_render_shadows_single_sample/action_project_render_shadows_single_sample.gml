/// action_project_render_shadows_single_sample(enable)
/// @arg enable

function action_project_render_shadows_single_sample(enable)
{
	action_project_render_preset_edit_locked()

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_single_sample, render_preset_edit.renderer[renderer_edit].shadows_single_sample, enable, true)

	render_preset_edit.renderer[renderer_edit].shadows_single_sample = enable
	project_render_shadows_single_sample = enable
	render_samples = -1
}
