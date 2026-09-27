/// action_project_render_shadows_jittered(enable)
/// @arg enable

function action_project_render_shadows_jittered(enable)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_jittered, render_preset_edit.renderer[renderer_edit].shadows_jittered, enable, true)
	
	render_preset_edit.renderer[renderer_edit].shadows_jittered = enable
	project_render_shadows_jittered = enable
	render_samples = -1
}
