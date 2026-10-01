function popup_loading_draw()
{	
	dx += 8
	dy += 8
	dw -= 16
	dh -= 16
	
	if (popup_current.load_amount > 1)
	{
		var objprogress = (popup_current.progress = 1 ? 0 : popup_current.progress);
		var progress = (popup_current.load_amount - (ds_priority_size(load_queue) - objprogress)) / popup_current.load_amount;
		
		tab_control_loading()
		draw_loading_bar(dx, dy, dw, 8, progress, text_get("loading/resources"), text_get("loading/percent", string(floor(progress * 100))))
		tab_next()
	}
	
	tab_control_loading()
	draw_loading_bar(dx, dy, dw, 8, popup_current.progress, popup_current.caption, popup_current.text)
	tab_next()

	// Load the next stage
	if (popup_ani = 1 && popup_current.load_object && popup_current.load_script)
		with (popup_current.load_object)
			script_execute(app.popup_current.load_script)
}
