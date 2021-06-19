/// popup_close()

function popup_close()
{
	if (popup = popup_modelbench)
		popup_modelbench.not_now = true
	
	window_busy = ""
	window_focus = ""
	popup_ani_type = "hide"
	app_mouse_clear()
}
