/// action_project_render_cache_data_buffers(enable)

function action_project_render_cache_data_buffers(enable)
{
	action_project_render_preset_edit_locked()

	if (!history_undo && !history_redo)
		history_set_var(action_project_render_cache_data_buffers, render_preset_edit.renderer[renderer_edit].cache_data_buffers, enable, true)

	render_preset_edit.renderer[renderer_edit].cache_data_buffers = enable
	render_samples = -1
}
