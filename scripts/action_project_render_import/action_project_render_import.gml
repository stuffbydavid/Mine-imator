/// action_project_render_import()

function action_project_render_import()
{
	var fn = file_dialog_open_render();
	
	if (fn = "")
		return 0
	
	var map = project_load_start(fn);
	if (map = null)
		return 0
	
	project_load_render(map[?"render"])
	ds_map_destroy(map)
	
	log("Loaded render settings", fn)
}