/// app_startup_interface()

function app_startup_interface()
{
	app_startup_shortcut_bar()
	app_startup_interface_bench()
	app_startup_interface_timeline()
	app_startup_interface_export()
	app_startup_interface_menus()
	app_startup_interface_settings_menus()
	app_startup_interface_popups()
	app_startup_interface_panels()
	app_startup_interface_tabs()
	app_startup_interface_toolbar()
	app_startup_interface_views()
	app_startup_interface_world_import()
	app_startup_interface_context_menu()
	togglebutton_reset()
	
	textbox_startup()
	history_startup()
	textfield_group_reset()
	
	background_ground_startup()
	background_sky_startup()
	
	// Run tests
	if (test_project != "")
	{
		if (!project_load(test_project)) {
			error("errortest")
			game_end()
		}
		else
			tests_run()
		return 0
	}
	
	// Shortcut to a debugging project
	else if (debug_mode)
	{
		popup_newproject_clear()
		
		if (debug_project != "")
		{
			project_reset()
			
			if (!file_exists_lib(debug_project))
			{
				setting_project_folder = filename_dir(filename_dir(debug_project)) + "/"
				popup_newproject.folder = filename_name(filename_dir(debug_project))
				popup_newproject.tbx_name.text = string_replace(filename_name(debug_project), filename_ext(debug_project), "")
				project_create()
			}
			project_load(debug_project)
		}
		else
		{
			var projfile = setting_project_folder + popup_newproject.folder + "/New Project.miproject";
			if (!file_exists_lib(projfile))
				project_create()
			project_load(projfile)
		}
		
		window_state = ""
	}
	
	// Show welcome screen
	else
	{
		// Start server request for new assets
		http_assets = http_get(link_assets_versions)
	
		project_reset()
		
		// First start
		if (!file_exists_lib(settings_file))
			popup_show(popup_welcome)
	}
	
	window_main_restore(setting_main_window_rect, setting_main_window_maximized)
}
