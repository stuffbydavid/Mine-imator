function action_project_render_material_maps(enabled)
{
	if (!history_undo && !history_redo)
		history_set_var(action_project_render_material_maps, project_render_material_maps, enabled, true)
	
	project_render_material_maps = enabled
	render_samples = -1
	project_update_counts()
}
