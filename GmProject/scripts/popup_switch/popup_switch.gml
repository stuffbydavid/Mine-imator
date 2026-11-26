function popup_switch(popup)
{
	if (popup_current = null)
	{
		popup_show(popup)
		return 0
	}
	
	popup_switch_to = popup
	popup_switch_from = popup_current
	popup_ani_type = "hide"
	
	window_busy = "popup/" + popup_switch_to.name
}
