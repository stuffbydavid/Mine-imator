/// action_project_render_shaderpack(name)
/// @arg name

function action_project_render_shaderpack(name)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_shaderpack, project_render_shaderpack, name, 0)
	
	project_render_shaderpack = name
	shaderpack_update()
	render_samples = -1
}
