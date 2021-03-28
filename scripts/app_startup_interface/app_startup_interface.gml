/// app_startup_interface()

window_maximize()

app_startup_shortcut_bar()
app_startup_interface_bench()
app_startup_interface_timeline()
app_startup_interface_export_movie()
app_startup_interface_menus()
app_startup_interface_settings_menus()
app_startup_interface_popups()
app_startup_interface_panels()
app_startup_interface_tabs()
app_startup_interface_toolbar()
app_startup_interface_views()
app_startup_interface_context_menu()
app_startup_interface_sidemenu()
togglebutton_reset()

textbox_startup()
history_startup()
textfield_group_reset()

background_ground_startup()
background_sky_startup()
	
// Start server request for new assets
http_assets = http_get(link_assets_versions)

// Shortcut to a new project
if (dev_mode)
{
	popup_newproject_clear()
	project_create()
	window_state = ""
}
else
{
	project_reset()
}