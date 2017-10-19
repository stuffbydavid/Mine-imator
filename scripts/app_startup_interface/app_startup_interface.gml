/// app_startup_interface()

window_maximize()

app_startup_interface_timeline()
app_startup_interface_export_movie()
app_startup_interface_menus()
app_startup_interface_popups()
app_startup_interface_panels()
app_startup_interface_tabs()
app_startup_interface_tips()
app_startup_interface_toolbar()
app_startup_interface_views()

textbox_startup()
alert_startup()
history_startup()

background_ground_startup()
background_sky_startup()

// Shortcut to a new project
if (dev_mode)
{
	popup_newproject_clear()
	project_create()
}
else
{
	project_reset()
	
	if(ds_list_empty(content_list))
		popup_show(popup_startup)
	else
		popup_show(popup_download)
}