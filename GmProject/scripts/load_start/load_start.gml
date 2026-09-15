/// load_start(object, script)
/// @arg object
/// @arg script

function load_start(object, script)
{
	if (popup != popup_loading)
	{
		popup = popup_loading
		popup_ani = 0
		popup_ani_type = "show"
	}
	
	if (popup = popup_loading && popup_ani != 1)
		popup.load_amount = ds_priority_size(load_queue)
	
	with (popup_loading)
	{
		caption = ""
		progress = 0
		load_object = object
		load_script = script
		load_drawn = false
	}

	// Show resource name before the first loading frame
	with (object)
		other.popup_loading.caption = filename
	
	window_busy = "popup" + popup.name
}
