/// load_start(object, script)
/// @arg object
/// @arg script

popup = popup_loading
popup_ani = 1
popup_ani_type = ""

with (popup_loading)
{
	caption = ""
	progress = 0
	load_object = argument0
	load_script = argument1
}

window_busy = "popup" + popup.name