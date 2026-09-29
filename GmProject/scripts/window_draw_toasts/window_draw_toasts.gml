/// @desc Draws all active toasts.

function window_draw_toasts()
{
	toast_mouseon = false
	
	var busy = window_busy;
	if (popup_current && busy = "popup" + popup_current.name)
		window_busy = "" 
	
	for (var i = toast_amount - 1; i >= 0; i--)
	{
		var toast = toast_list[|i];
		
		draw_set_alpha(ease("easeoutcirc", toast.remove_alpha))
		toast_draw(toast)
		draw_set_alpha(1)
	}
	
	window_busy = busy 
}
