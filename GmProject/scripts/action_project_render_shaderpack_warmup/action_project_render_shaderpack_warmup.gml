/// action_project_render_shaderpack_warmup(value, add)
/// @arg value
/// @arg add

function action_project_render_shaderpack_warmup(val, add)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shaderpack_warmup, project_render_shaderpack_warmup, project_render_shaderpack_warmup * add + val, 1)
	
	project_render_shaderpack_warmup = project_render_shaderpack_warmup * add + val
	render_samples = -1
}
