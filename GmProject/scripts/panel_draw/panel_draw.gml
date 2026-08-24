function test_reduced_motion(a, b)
{
	if (app.setting_reduced_motion)
		return a
	return b
}

/// panel_draw(panel)
/// @arg panel
function panel_draw(panel)
{
	if (panel.size_real < 1 && !panel.glow && panel != panel_window_obj)
		return 0
	
	var boxx, boxy, boxw, boxh, resizemouseon, padding;
	var tabtitle, tabx, tabw, tabmaxw, tabsw, tabswprev, tabsh, tablistmouseon, tabmouseon;
	var dx, dy;
	
	// Calculate box
	if (panel = panel_map[?"bottom"])
	{ 
		boxx = panel_area_x + panel_map[?"left"].size_real_ani 
		boxy = panel_area_y + panel_area_height - panel.size_real_ani 
		boxw = panel_area_width - panel_map[?"left"].size_real_ani - panel_map[?"right"].size_real_ani 
		boxh = panel.size_real_ani 
		content_direction = e_scroll.HORIZONTAL 
		if (panel.glow) 
			draw_box(boxx, boxy + boxh - panel.size, boxw, panel.size_glow, false, c_accent, glow_alpha)
	}
	else if (panel = panel_map[?"top"]) 
	{ 
		boxx = panel_area_x + panel_map[?"left"].size_real_ani 
		boxy = panel_area_y 
		boxw = panel_area_width - panel_map[?"left"].size_real_ani - panel_map[?"right"].size_real_ani 
		boxh = panel.size_real_ani 
		content_direction = e_scroll.HORIZONTAL 
		if (panel.glow) 
			draw_box(boxx, boxy, boxw, panel.size_glow, false, c_accent, glow_alpha) 
	}
	else if (panel = panel_map[?"left"])
	{
		boxx = panel_area_x
		boxy = panel_area_y + panel_map[?"top"].size_real_ani 
		boxw = panel.size_real_ani
		boxh = panel_area_height - panel_map[?"top"].size_real_ani 
		content_direction = e_scroll.VERTICAL
		
		if (panel.glow)
			draw_box(boxx, boxy, panel.size_glow, boxh, false, c_accent, glow_alpha)
	}
	else if (panel = panel_map[?"left_secondary"])
	{
		boxx = panel_area_x + panel_map[?"left"].size_real_ani
		boxy = panel_area_y + panel_map[?"top"].size_real_ani 
		boxw = panel.size_real_ani
		boxh = panel_area_height - panel_map[?"top"].size_real_ani - panel_map[?"bottom"].size_real_ani 
		content_direction = e_scroll.VERTICAL
		
		if (panel.glow)
			draw_box(boxx, boxy, panel.size_glow, boxh, false, c_accent, glow_alpha)
	}
	else if (panel = panel_map[?"right"])
	{
		boxx = panel_area_x + panel_area_width - panel.size_real_ani
		boxy = panel_area_y + panel_map[?"top"].size_real_ani 
		boxw = panel.size_real_ani
		boxh = panel_area_height - panel_map[?"top"].size_real_ani 
		content_direction = e_scroll.VERTICAL
		
		if (panel.glow)
			draw_box(boxx + boxw - panel.size_glow, boxy, panel.size_glow, boxh, false, c_accent, glow_alpha)
	}
	else if (panel = panel_map[?"right_secondary"])
	{
		boxx = panel_area_x + panel_area_width - panel_map[?"right"].size_real_ani - panel.size_real_ani
		boxy = panel_area_y + panel_map[?"top"].size_real_ani 
		boxw = panel.size_real_ani
		boxh = panel_area_height - panel_map[?"top"].size_real_ani - panel_map[?"bottom"].size_real_ani 
		content_direction = e_scroll.VERTICAL
		
		if (panel.glow)
			draw_box(boxx + boxw - panel.size_glow, boxy, panel.size_glow, boxh, false, c_accent, glow_alpha)
	}
	else if (panel = panel_window_obj)
	{
		boxx = 0
		boxy = 0
		boxw = window_width
		boxh = window_height
	}
	
	if (boxw < 1 || boxh < 1)
		return 0
	
	if (panel.tab_list_amount = 0)
		return 0
	
	boxx = floor(boxx)
	boxy = floor(boxy)
	boxw = ceil(boxw)
	boxh = ceil(boxh)
	
	// Background
	draw_box(boxx, boxy, boxw, boxh, false, c_level_middle, 1)
	
	// Content
	tabsh = min(boxh, 24)
	content_tab = panel.tab_list[panel.tab_selected]
	content_x = boxx
	content_y = boxy + (tabsh * content_tab.movable)
	content_width = boxw
	content_height = boxh - (tabsh * content_tab.movable)
	content_mouseon = (app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	panel_compact = (panel.size_real <= 225)
	panel_draw_content()
	content_y = boxy
	
	// Tabs
	tabsw = 0
	tabswprev = 0
	tabmaxw = boxw
	padding = 10
	tablistmouseon = null
	tabmouseon = false
	
	if (content_tab.movable)
	{
		if (panel.tab_list_amount > 0)
		{
			// Get full width of all tabs
			for (var t = 0; t < panel.tab_list_amount; t++)
			{
				var tab, sel;
				tab = panel.tab_list[t]
				sel = (panel.tab_selected = t)
				
				tabtitle[t] = tab_get_title(tab)
				
				draw_set_font(sel ? font_label : font_value)
				tabw[t] = string_width(tabtitle[t]) + 8
				
				if (tab.closeable)
					tabw[t] += 36
				else
					tabw[t] += 16
				
				tabswprev += tabw[t]
			}
			
			// Adjust tab widths
			var selnamew, unselnamew;
			selnamew = tabw[panel.tab_selected];
			unselnamew = max(28, (boxw - selnamew) / (panel.tab_list_amount - 1)) // Set new unactive tab save
			selnamew = min(selnamew, 144, boxw - (unselnamew * (panel.tab_list_amount - 1))) // Update tab size based on new unactive tab save
			unselnamew = max(28, (boxw - selnamew) / (panel.tab_list_amount - 1)) // Update unactive tab size based on new active tab size
			unselnamew = min(unselnamew, 144)
			
			for (var t = 0; t < panel.tab_list_amount; t++)
			{
				var tab, sel;
				tab = panel.tab_list[t]
				sel = (panel.tab_selected = t)
				
				if (sel)
				{
					tabw[t] = min(144, tabw[t], selnamew)
					tabsw += tabw[t]
				}
				else
				{
					tabw[t] = min(144, tabw[t], unselnamew)
					tabsw += tabw[t]
				}
			}
		}
		
		dx = boxx
		dy = boxy
		content_mouseon = !popup_mouseon && !toast_mouseon && !context_menu_mouseon
		
		// Tabs background
		draw_box(dx, dy, tabmaxw, tabsh, false, c_level_bottom, 1)
		
		draw_box(dx, dy + tabsh, tabmaxw, 1, false, c_border, a_border)
		
		for (var t = 0; t < panel.tab_list_amount; t++)
		{
			var tab, sel, dw, dh, hover;
			tab = panel.tab_list[t]
			sel = (panel.tab_selected = t)
			
			tabx[t] = dx
			
			dw = tabw[t]
			dh = tabsh
			hover = false
			
			// Mouseon
			if (app_mouse_box(dx, dy, dw, dh))
			{
				hover = true
				
				if (!app_mouse_box(dx + dw - (20 * tab.closeable), dy + 4, 16 * tab.closeable, 16))
				{
					if (!sel)
					{
						tablistmouseon = t
						mouse_cursor = cr_handpoint
					}
					else
						tabmouseon = true
				}
			}
			
			if (sel)
				draw_box(dx, dy, dw, dh + 1, false, c_level_middle, 1)
			
			var limit = dw - 16;
			
			if ((hover || sel) && tab.closeable)
				limit -= 20
			
			draw_set_font(sel ? font_label : font_value)
			
			if (string_width(tabtitle[t]) > limit)
				tip_set(tabtitle[t], dx, dy, dw, dh)
			
			tabtitle[t] = string_limit(tabtitle[t], limit)
			
			// Close button
			if (tab.closeable && (hover || sel))
			{
				if (hover && mouse_middle_pressed)
				{
					tab_close(tab)
					return 0
				}
				
				if (draw_button_icon("tabclose" + string(tab), floor(dx + dw - 20), dy + 4, 16, 16, false, icons.CLOSE_SMALL))
				{
					tab_close(tab)
					return 0
				}
			}
			
			// Label
			draw_label(tabtitle[t], floor(dx + 8), round(dy + (dh/2)), fa_left, fa_center, (sel ? c_accent : (hover ? c_text_main : c_text_secondary)), (sel ? 1 : (hover ? a_text_main : a_text_secondary)), sel ? font_label : font_value)
			
			// Outline/border
			if (sel)
			{
				if (t != 0)
					draw_box(dx - 1, dy, 1, dh, false, c_border, a_border)
				
				draw_box(dx + dw - 1, dy, 1, dh + 1, false, c_border, a_border)
			}
			else
			{
				if (t < panel.tab_list_amount)
				{
					if (panel.tab_selected != t + 1)
						draw_box(dx + dw, dy, 1, dh, false, c_border, a_border)
				}
			}
			
			// List glow
			tab.glow = max(0, tab.glow - 0.05)
			if (window_busy = "tabmove")
			{
				window_busy = ""
				if (app_mouse_box(dx, dy, dw, dh))
				{
					tab.glow = test_reduced_motion(1, min(1, tab.glow + 0.1 * delta))
					tab.panel_last = panel
					tab_move_mouseon_panel = panel
					tab_move_mouseon_position = t
				}
				window_busy = "tabmove"
			}
			
			if (tab.glow > 0)
				draw_box(dx, dy, dw, dh, false, c_accent, tab.glow * glow_alpha)
			
			dx += tabw[t]
		}
		
		// Panel edge
		if (panel = panel_map[?"right"] || panel = panel_map[?"right_secondary"])
			draw_box(boxx, boxy, 1, boxh, false, c_border, a_border)
		else
			draw_box(boxx + boxw - 1, boxy, 1, boxh, false, c_border, a_border)
		
		panel.list_glow = test_reduced_motion(0, max(0, panel.list_glow - 0.05 * delta))
		if (tabmaxw > tabsw)
		{
			// Moving?
			if (window_busy = "tabmove")
			{
				window_busy = ""
				if (app_mouse_box(boxx + tabsw, boxy, tabmaxw - tabsw, tabsh))
				{
					panel.list_glow = test_reduced_motion(1, min(1, panel.list_glow + 0.1 * delta))
					tab_move_mouseon_panel = panel
					tab_move_mouseon_position = panel.tab_list_amount
				}
				window_busy = "tabmove"
			}
			
			// Glow for new tab
			if (panel.list_glow > 0)
				draw_box(boxx + tabsw, boxy, min(tab_move_width, tabmaxw - tabsw), tabsh, false, c_accent, panel.list_glow * glow_alpha)
		}
		
		// Glow
		if (content_tab.glow > 0)
			draw_box(boxx, boxy + tabsh, boxw, boxh - tabsh, false, c_accent, content_tab.glow * glow_alpha)
	}
	
	// Border
	resizemouseon = false
	if (panel = panel_map[?"left"] || panel = panel_map[?"left_secondary"])
	{
		draw_gradient(boxx + boxw, boxy, shadow_size, boxh, c_black, shadow_alpha, 0, 0, shadow_alpha)
		if (app_mouse_box(boxx + boxw - 8, boxy, 8, boxh) && tablistmouseon = null && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		{
			mouse_cursor = cr_size_we
			resizemouseon = true
		}
		
		if (resizemouseon || panel = panel_resize)
			draw_box(boxx + boxw - 2, boxy, 4, boxh, false, c_hover, a_hover)
	}
	else if (panel = panel_map[?"right"] || panel = panel_map[?"right_secondary"])
	{
		draw_gradient(boxx - shadow_size, boxy, shadow_size, boxh, c_black, 0, shadow_alpha, shadow_alpha, 0)
		if (app_mouse_box(boxx, boxy, 8, boxh) && tablistmouseon = null && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		{
			mouse_cursor = cr_size_we
			resizemouseon = true
		}
		
		if (resizemouseon || panel = panel_resize)
			draw_box(boxx - 2, boxy, 4, boxh, false, c_hover, a_hover)
	}
	else if (panel = panel_map[?"bottom"])
	{
		draw_gradient(boxx, boxy - shadow_size, boxw, shadow_size, c_black, 0, 0, shadow_alpha, shadow_alpha) 
		if (app_mouse_box(boxx, boxy, boxw, 8) && tablistmouseon = null && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		{
			mouse_cursor = cr_size_ns
			resizemouseon = true
		}
		
		if (resizemouseon || panel = panel_resize)
			draw_box(boxx, boxy - 2, boxw, 4, false, c_hover, a_hover)
	}
	
	// Resize
	if (resizemouseon && mouse_left_pressed)
	{
		window_busy = "panelresize"
		panel_resize = panel
		panel_resize_size = panel.size_real
	}
	
	// Move
	if (tabmouseon && mouse_cursor = cr_default && mouse_left_pressed)
	{
		window_busy = "tabclick"
		tab_move = content_tab
	}
	
	if (window_busy = "tabclick")
	{
		if (tab_move = null) // Tab was closed
			window_busy = ""
		else if (tab_move = content_tab)
		{
			if (mouse_move > 10)
			{
				window_busy = "tabmove"
				tab_move_name = tabtitle[panel.tab_selected]
				tab_move_x = min(boxw - tabw[panel.tab_selected], tabx[panel.tab_selected] - boxx)
				tab_move_width = tabw[panel.tab_selected]
				tab_move_direction = content_direction
				tab_move_box_x = boxx - mouse_x
				tab_move_box_y = boxy - mouse_y
				tab_move_box_width = boxw
				tab_move_box_height = boxh
				panel_tab_list_remove(panel, panel.tab_list[panel.tab_selected])
			}
			else if (!mouse_left)
				window_busy = ""
		}
	}
	
	// Click tab list
	if (tablistmouseon != null && mouse_left_pressed)
	{
		panel.tab_selected = tablistmouseon
		window_busy = "tabclick"
		tab_move = panel.tab_list[tablistmouseon]
	}
}
