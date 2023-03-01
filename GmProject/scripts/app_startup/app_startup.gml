/// app_startup()

function app_startup()
{
	startup_error = true
	
	if (!lib_startup())
		return false
	
	if (!is_cpp()) // Skip file lib in C++
		if (!file_lib_startup())
			return false
	
	if (!file_exists_lib(legacy_file))
		return missing_file(legacy_file)
	
	if (!file_exists_lib(language_file))
		return missing_file(language_file)
	
	vertex_format_startup()
	if (!shader_startup())
		return false
	
	if (!legacy_startup())
		return false
	
	app_startup_lists()
	app_startup_collapse()
	app_startup_micro_animations()
	app_startup_window()
	app_startup_themes()
	app_startup_fonts()
	app_startup_interface_lists()
	app_startup_keybinds()
	
	app_startup_recent()
	toasts_startup()
	json_startup()
	settings_startup()
	project_startup()
	render_startup()
	camera_startup()
	
	if (!minecraft_assets_startup())
		return false
	
	startup_error = false
	
	return true
}
