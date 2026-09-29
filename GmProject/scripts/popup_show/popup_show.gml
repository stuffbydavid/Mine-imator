function popup_show(popup)
{
	if (!popup_current)
	{
		popup_ani = 0
		popup_ani_type = "show"
	}
	
	popup_current = popup
	
	log("Show popup", popup_current.name)
	
	if (popup_current.block)
		window_busy = "popup" + popup_current.name
	
	action_tl_play_break()
	context_menu_close()
}
