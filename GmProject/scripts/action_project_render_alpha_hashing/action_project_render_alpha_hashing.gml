/// action_project_render_alpha_hashing(enable)
/// @arg enable

function action_project_render_alpha_hashing(enable)
{
	action_project_render_preset_edit_locked()

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_alpha_hashing, render_preset_edit.renderer[renderer_edit].alpha_hashing, enable, true)

	render_preset_edit.renderer[renderer_edit].alpha_hashing = enable
	project_render_alpha_hashing = enable
	render_samples = -1
}
