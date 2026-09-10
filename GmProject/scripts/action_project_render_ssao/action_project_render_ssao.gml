/// action_project_render_ssao(enable)
/// @arg enable

function action_project_render_ssao(enable)
{
	action_project_render_preset_edit_locked()
	
	var settings = render_preset_edit.renderer[renderer_edit]
	
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_ssao, settings.ssao, enable, true)
	
	settings.ssao = enable
}
