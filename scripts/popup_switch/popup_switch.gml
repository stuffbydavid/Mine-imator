/// popup_switch(popup)
/// @arg popup

if (popup = null)
{
	popup_show(argument0)
	return 0
}

popup_switch_to = argument0
popup_switch_from = popup
window_busy = "popup" + popup_switch_to.name
popup_ani_type = "hide"
