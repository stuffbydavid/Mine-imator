/// action_project_render_material_maps(enable)
/// @arg enable

function action_project_render_material_maps(enable)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_material_maps, project_render_material_maps, enable, 1)
	
	project_render_material_maps = enable
	render_samples = -1
}
