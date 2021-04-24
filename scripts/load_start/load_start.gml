/// load_start(object, script)
/// @arg object
/// @arg script

function load_start(object, script)
{
	popup = popup_loading
	popup_ani = 1
	popup_ani_type = ""
	
	with (popup_loading)
	{
		caption = ""
		progress = 0
		load_object = object
		load_script = script
	}
	
	window_busy = "popup" + popup.name
}
