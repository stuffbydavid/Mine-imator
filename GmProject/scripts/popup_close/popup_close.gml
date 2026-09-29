function popup_close()
{
	if (popup_current = popup_modelbench)
		popup_modelbench.not_now = true
	
	if (popup_current = popup_upgrade)
		popup_upgrade.open_advanced = false
	
	if (popup_current = popup_importimage)
		ds_list_clear(popup_importimage.filenames)
	
	window_busy = ""
	window_focus = ""
	
	popup_ani_type = "hide"
	
	app_mouse_clear()
}
