/// sortlist_draw(sortlist, x, y, width, height, select, [filter, [name]])
/// @arg sortlist
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg select
/// @arg [filter
/// @arg [name]]
/// @desc Draws the given sorted list at x, y. Runs a script when a new value is selected.

function sortlist_draw(slist, xx, yy, w, h, select, filter = true, name = "")
{
	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
	{
		if (textbox_jump)
			ds_list_add(textbox_list, [slist.search_tbx, content_tab, yy, content_y, content_height])
		
		return 0
	}
	
	var colmouseon, searchx, searchw, itemh, colsh, dy;
	
	searchx = xx
	searchw = w
	
	// Item height
	itemh = ui_small_height
	
	// Columns
	colsh = ui_small_height
	
	// Draw filter
	if (filter && name = "")
	{
		if (draw_button_icon("listfilter" + string(slist), xx, yy, 24, 24, !ds_list_empty(slist.filter_list), icons.FILTER, null, false, "tooltipfilterlist"))
		{
			menu_settings_set(xx, yy, "listfilter" + string(slist), 24)
			settings_menu_script = sortlist_filters_draw
			settings_menu_sortlist = slist
			settings_menu_h_max = 256
		}
		
		if ((settings_menu_name = "listfilter" + string(slist)) && settings_menu_ani_type != "hide")
			current_microani.active.value = true
		
		searchx += 32
		searchw -= 32
	}
	
	// Name
	if (name != "")
	{
		draw_set_font(font_label)
		draw_label(string_limit(name, w - 144), xx, yy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		
		searchx += (w - 144)
		searchw -= (w - 144)
	}
	
	if (draw_textfield("listsearch" + string(slist), searchx, yy, searchw, 24, slist.search_tbx, null, text_get("listsearch"), "none"))
	{
		slist.search = (slist.search_tbx.text != "")
		sortlist_update(slist)
	}
	
	h -= 32
	yy += 32
	
	if (h < colsh)
		return 0
	
	colmouseon = app_mouse_box(xx, yy, w, colsh) && content_mouseon
	
	// Dragging
	if (window_busy = "sortlist_resize" && sortlist_resize = slist)
	{
		slist.column_x[sortlist_resize_column] = sortlist_resize_column_x + (mouse_x - mouse_click_x) / w
		slist.column_x[sortlist_resize_column] = clamp(0, slist.column_x[sortlist_resize_column], 0.9)
		if (sortlist_resize_column > 0)
			slist.column_x[sortlist_resize_column] = max(slist.column_x[sortlist_resize_column], slist.column_x[sortlist_resize_column - 1] + 0.1)
		if (sortlist_resize_column < slist.columns - 1)
			slist.column_x[sortlist_resize_column] = min(slist.column_x[sortlist_resize_column], slist.column_x[sortlist_resize_column + 1] - 0.1)
		
		mouse_cursor = cr_size_we
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	for (var c = 0; c < slist.columns; c++)
	{
		var dx, icon;
		dx = floor(slist.column_x[c] * w)
		
		// Set width
		if (c = slist.columns - 1)
			slist.column_w[c] = ceil(w - dx)
		else
			slist.column_w[c] = ceil(slist.column_x[c + 1] * w) - dx
		
		// Resize?
		if (c > 0 && app_mouse_box(xx + dx - 5, yy, 10, colsh) && content_mouseon)
		{
			mouse_cursor = cr_size_we
			if (mouse_left_pressed)
			{
				sortlist_resize = slist
				sortlist_resize_column = c
				sortlist_resize_column_x = slist.column_x[c]
				window_busy = "sortlist_resize"
			}
		}
		
		// Button
		icon = null
		if (slist.column_sort = c)
			icon = (slist.sort_asc ? icons.SORT_UP : icons.SORT_DOWN)
		
		if (sortlist_draw_button("column" + slist.column_name[c], xx + dx, yy + 4, slist.column_w[c], colsh, slist.column_sort = c, icon, (c = 0), (c = slist.columns - 1), colmouseon))
		{
			if (slist.column_sort = c)
			{
				if (slist.sort_asc)
				{
					slist.column_sort = null
					slist.sort_asc = false
				}
				else
					slist.sort_asc = true
			}
			else
				slist.column_sort = c
		
			sortlist_update(slist)
		}
	}
	
	// Items
	dy = (yy + colsh) + 10
	
	draw_divide(xx + 1, dy - 3, w - 2)
	
	// Outline
	if (window_focus = string(slist.scroll))
	{
		draw_outline(xx, yy, w, h, 1, c_accent, 1, true)
		window_scroll_focus = string(slist.scroll)
		
		if (!app_mouse_box(xx, yy, w, h) && content_mouseon && mouse_left && window_busy != "scrollbar")
			window_focus = ""
	}
	else
		draw_outline(xx, yy, w, h, 1, c_border, a_border, true)
	
	// List
	draw_set_font(font_value)
	
	for (var i = round(slist.scroll.value / itemh); i < ds_list_size(slist.display_list); i++)
	{
		if (dy + itemh > yy + h)
			break
		
		var value, dw, selected, mouseon;
		value = slist.display_list[|i]
		dw = w - 12 * slist.scroll.needed
		selected = (select = value)
		mouseon = (app_mouse_box(xx, dy, dw, itemh) && content_mouseon)
		
		if (selected || mouseon && mouse_left)
		{
			draw_box(xx, dy, dw, itemh, false, c_accent_overlay, a_accent_overlay)
			
			if (mouseon && mouse_left)
				draw_box_hover(xx, dy, dw, itemh, 1)
		}
		else if (mouseon)
			draw_box(xx, dy, dw, itemh, false, c_overlay, a_overlay)
		
		for (var c = 0; c < slist.columns; c++)
		{
			var dx, text, wid, islast;
			dx = xx + floor(slist.column_x[c] * w) + 8
			wid = slist.column_w[c] - 8
			if (c = slist.columns - 1 && slist.scroll.needed)
				wid -= 12
			
			islast = (c = slist.columns - 1) && (c != 0)
			
			/*
			if (slist.columns = 1 && selected)
			{
				draw_image(spr_icons, icons.TICK, xx + dw - 16, dy + itemh/2, 1, 1, c_accent, 1)
				wid -= 32
			}
			*/
			
			text = string_limit(string(sortlist_column_get(slist, value, c)), wid)
			draw_label(text, dx + ((wid - 8) * islast), dy + itemh / 2, islast ? fa_right : fa_left, fa_middle, selected ? c_accent : c_text_main, selected ? 1 : a_text_main)
		}
		
		if (mouseon)
		{
			mouse_cursor = cr_handpoint
			if (mouse_left_released)
			{
				if (slist.can_deselect && selected)
					script_execute(slist.script, null)
				else
					script_execute(slist.script, value)
				app_mouse_clear()
				
				if (slist.scroll.needed)
					window_focus = string(slist.scroll)
			}
		}
		
		dy += itemh
	}
	
	// Scrollbar
	slist.scroll.snap_value = itemh
	scrollbar_draw(slist.scroll, e_scroll.VERTICAL, xx + w - 12, yy + (colsh + 10), floor((h - (colsh + 10)) / itemh) * itemh, ds_list_size(slist.display_list) * itemh)
}
