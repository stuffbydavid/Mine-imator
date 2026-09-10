/// action_project_render_preset_reset()

function action_project_render_preset_reset()
{
	var fn;
	if (render_preset_edit.file = "custom")
		fn = render_default_file
	else
		fn = render_directory + render_preset_edit.file
	
	return action_project_render_preset_import(fn)
}
