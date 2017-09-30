/// app_startup()

startup_last_crash = false
startup_error = true

if (!log_startup())
	return false

lib_startup()

if (!file_lib_startup())
	return false
	
if (!file_exists_lib(import_file))
{
	missing_file(import_file)
	return false
}

if (!file_exists_lib(legacy_file))
{
	missing_file(legacy_file)
	return false
}

vertex_format_startup()
if (!shader_startup())
	return false

app_startup_globals()
app_startup_lists()

if (!minecraft_assets_startup())
	return false
	
app_startup_window()
app_startup_history()
app_startup_timeline()
app_startup_exportmovie()
app_startup_interface_menus()
app_startup_interface_popups()
app_startup_interface_panels()
app_startup_interface_tabs()
app_startup_interface_tips()
app_startup_interface_toolbar()
app_startup_interface_views()

project_legacy_startup()
textbox_startup()
trial_startup()
alert_startup()
settings_startup()
render_startup()
background_ground_startup()
background_sky_startup()
alert_show("A title","some text",icons.WEBSITE_SMALL)
log("Startup OK")
startup_error = false

return true
