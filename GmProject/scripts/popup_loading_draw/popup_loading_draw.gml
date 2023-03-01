/// popup_loading_draw()

function popup_loading_draw()
{	
	if (popup_ani = 1)
	{
		if (popup.load_object && popup.load_script)
			with (popup.load_object)
				script_execute(app.popup.load_script)
	}
	
	dx += 8
	dy += 8
	dw -= 16
	dh -= 16
	
	if (popup.load_amount > 1)
	{
		var object_progress = (popup.progress = 1 ? 0 : popup.progress);
		var progress = (popup.load_amount - (ds_priority_size(load_queue) - object_progress)) / popup.load_amount;
		
		tab_control_loading()
		draw_loading_bar(dx, dy, dw, 8, progress, text_get("loadingresources"), text_get("loadingpercent", string(floor(progress * 100))))
		tab_next()
	}
	
	tab_control_loading()
	draw_loading_bar(dx, dy, dw, 8, popup.progress, popup.caption, popup.text)
	tab_next()
}
