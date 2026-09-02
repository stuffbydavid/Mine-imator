/// action_load_render_settings(fn)
/// @desc Only used when creating a new project or opening a project with a render settings file selected

function action_load_render_settings(fn)
{
	var map = project_load_start(fn);
	if (map = null)
		return 0
	
	project_load_render(map[?"render"])
	ds_map_destroy(map)
}