/// popup_show(popup)
/// @arg popup

if (!popup)
{
	popup_ani = 0
	popup_ani_type = "show"
}

popup = argument0

log("Show popup", popup.name)

if (popup.block)
	window_busy = "popup" + popup.name

action_tl_play_break()
context_menu_close()
