/// popup_draw()

function popup_draw()
{
	var boxx, boxy, boxw, boxh, closex, closey;
	
	// Animate
	if (popup_ani = 1)
	{
		var off = (popup.custom_height_goal - popup.custom_height) / max(1, 4 / delta);
	
		if (off != 0)
		{
			popup.custom_height += off
			popup.offset_y += off/2
		}
	}
	else if (popup != null)
		popup.custom_height = popup.custom_height_goal
	
	if (popup_ani_type = "show")
	{
		popup_ani = min(1, popup_ani + 0.075 * delta)
		if (popup_ani = 1)
			popup_ani_type = ""
	}
	else if (popup_ani_type = "hide")
	{
		popup_ani = max(0, popup_ani - 0.075 * delta)
	
		if (popup_switch_to)
		{
			popup_ani = 0
			popup = popup_switch_to
			popup_switch_to = null
			popup_ani_type = "show"
			window_busy = ""
		}
		else if (popup_ani = 0)
		{
			window_busy = ""
			popup = null
			popup_ani_type = ""
			popup_switch_from = null
		}
	}
	
	if (!popup || (popup_ani_type = "hide" && popup_switch_to = null))
	{
		popup_block_ani = max(0, popup_block_ani - 0.075 * delta)
		popup_mouseon = false
		
		if (!popup)
			return 0
	}
	else
		popup_block_ani = min(1, popup_block_ani + 0.075 * delta)
	
	draw_set_alpha(ease("easeoutcirc", popup_ani))
	
	if (window_busy = "popupmove")
		draw_set_alpha(0.5)
	
	if (window_busy = "popup" + popup.name)
		window_busy = ""
	
	// Box
	boxw = popup.width
	boxh = floor(popup.custom_height)
	boxx = floor(popup.offset_x) + window_width / 2 - boxw / 2
	boxy = floor(popup.offset_y) + window_height / 2 - boxh / 2
	
	boxx = floor(boxx)
	boxy = floor(boxy)
	
	popup_mouseon = app_mouse_box(boxx, boxy, boxw, boxh)
	
	content_x = boxx
	content_y = boxy
	content_width = boxw
	content_height = boxh
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height)
	content_tab = null
	
	draw_dropshadow(boxx, boxy, boxw, boxh, c_black, 1) 
	draw_box(boxx, boxy, boxw, boxh, false, c_level_top, 1) 
	draw_outline(boxx, boxy, boxw, boxh, 1, c_border, a_border, true) 
	
	// Move
	if (window_busy = "popupclick")
	{
		if (mouse_move > 10)
		{
			popup_move_offset_x = popup.offset_x
			popup_move_offset_y = popup.offset_y
			window_busy = "popupmove"
		}
		else if (!mouse_left)
			window_busy = ""
	}
	
	if (window_busy = "popupmove")
	{
		popup.offset_x = popup_move_offset_x + (mouse_x - mouse_click_x)
		popup.offset_y = popup_move_offset_y + (mouse_y - mouse_click_y)
		if (!mouse_left)
			window_busy = ""
	}
	else
	{
		popup.offset_x = clamp(popup.offset_x, -(window_width - boxw) / 2, (window_width - boxw) / 2)
		popup.offset_y = clamp(popup.offset_y, -(window_height - boxh) / 2, (window_height - boxh) / 2)
	}
	
	// Draw contents
	dx = content_x
	dy = content_y
	dw = content_width
	dh = content_height
	
	dx_start = dx
	dy_start = dy
	
	// Adjust padding, add header
	if (!popup.custom)
	{
		dy += 12
		dx += 12
		dw -= 24
		dh -= 12
		
		// Caption
		draw_label(text_get(popup.name + "caption"), dx, dy + 12, fa_left, fa_middle, c_accent, 1, font_heading)
		
		closex = dx + dw - 24
		closey = dy
		
		dy += (24 + 12)
	}
	else
	{
		closex = (dx + dw) - (24 + 12)
		closey = dy + 12
	}
	
	// Close
	if (popup.close_button)
	{
		var revert = (popup.revert && popup_switch_from && popup_switch_from != popup);
		
		if (draw_button_icon(popup.name + "close", closex, closey, 24, 24, false, revert ? icons.ARROW_LEFT : icons.CLOSE, null, false))
		{
			if (revert)
				popup_switch(popup_switch_from)
			else
				popup_close()
		}
	}
	
	if (popup.script != null)
	{
		script_execute(popup.script)
		dy += 4
	}
	
	if (popup.custom || popup.height != null)
	{
		popup.custom_height_goal = popup.height
		popup.custom_height = popup.custom_height_goal
	}
	else
		popup.custom_height_goal = ceil((dy - dy_start) / 2) * 2
	
	if (popup_mouseon && mouse_cursor = cr_default && mouse_left_pressed)
		window_busy = "popupclick"
	
	if (window_busy = "" && popup.block)
		window_busy = "popup" + popup.name
	
	draw_set_alpha(1)
}
