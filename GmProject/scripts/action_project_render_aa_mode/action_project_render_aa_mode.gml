/// action_project_render_aa_mode(mode)
/// @arg mode

function action_project_render_aa_mode(mode)
{
	action_project_render_preset_edit_locked()

	var settings = render_preset_edit.renderer[renderer_edit];

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_aa_mode, settings.aa_mode, mode, true)

	settings.aa_mode = mode
	render_samples = -1
}
