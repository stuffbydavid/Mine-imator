/// action_project_render_shadows_transparent(enable)
/// @arg enable

function action_project_render_shadows_transparent(enable)
{
	action_project_render_preset_edit_locked()
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shadows_transparent, render_preset_edit.renderer[renderer_edit].shadows_transparent, enable, true)
	
	render_preset_edit.renderer[renderer_edit].shadows_transparent = enable
	render_samples = -1
}
