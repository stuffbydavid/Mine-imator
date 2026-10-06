/// action_project_render_shaderpack_options(options)
/// @arg options

function action_project_render_shaderpack_options(options)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shaderpack_options, project_render_shaderpack_options, options, 0)
	
	project_render_shaderpack_options = options
	shaderpack_update()
	render_samples = -1
}
