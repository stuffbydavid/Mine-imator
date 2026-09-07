/// action_project_render_preset(file)
/// @arg preset

function action_project_render_preset(file)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_preset, project_render_preset[renderer_edit], file, true)
		
	project_render_preset[renderer_edit] = file
	render_samples = -1
}