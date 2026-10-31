function action_project_render_preset_reset()
{
	if (render_preset_edit.file = "custom")
		action_project_render_preset_import(null)
	else
		action_project_render_preset_import(render_directory + render_preset_edit.file)
}
