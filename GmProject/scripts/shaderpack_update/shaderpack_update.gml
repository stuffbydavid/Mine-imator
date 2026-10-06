/// shaderpack_update()
/// @desc Loads or unloads the shaderpack selected in the project render settings.

function shaderpack_update()
{
	var path = "";
	if (project_render_shaderpack != "")
	{
		path = shaderpacks_directory + project_render_shaderpack
		if (!file_exists_lib(path) && !directory_exists_lib(path))
			path = project_render_shaderpack // Absolute path
	}
	
	if (path = "")
	{
		if (shaderpack_is_loaded())
			shaderpack_unload()
		
		shaderpack_loaded_key = ""
		render_samples = -1
		return 0
	}
	
	var key = path + "|" + project_render_shaderpack_options;
	if (key = shaderpack_loaded_key)
		return 0
	
	shaderpack_loaded_key = key
	if (!shaderpack_load(path, project_render_shaderpack_options))
		log("Could not load shaderpack", path, shaderpack_get_error())
	else
		log("Loaded shaderpack", path)
	
	render_samples = -1
}
