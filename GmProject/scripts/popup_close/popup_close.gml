/// popup_close()

function popup_close()
{
	if (popup = popup_modelbench)
		popup_modelbench.not_now = true
	
	if (popup = popup_upgrade)
	{
		popup_upgrade.open_advanced = false
		popup_upgrade.custom_rendering = "default"
	}
	
	if (popup = popup_importimage)
		ds_list_clear(popup_importimage.filenames)
	
	window_busy = ""
	window_focus = ""
	popup_ani_type = "hide"
	app_mouse_clear()
}
