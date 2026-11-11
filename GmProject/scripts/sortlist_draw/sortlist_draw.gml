/// @desc Draws the given sorted list at x, y. Runs a script when a new value is selected.
/// @arg sortlist
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg select
/// @arg [filter]
/// @arg [name]
/// @arg [state]

function sortlist_draw(slist, xx, yy, w, h, select, filter = true, name = "", state = null)
{
	var itemh, headerh, headermouseon, dy, listy, listhei, scrolloffset, ispicker;
	var searchfocused, searchunfocused, searchcleared, sortchanged;

	ispicker = (slist.object_index = obj_asset_picker)
	itemh = ui_small_height
	headerh = slist.header_show ? (ui_small_height + 8) : 0
	sortchanged = false

	// Header
	if (!draw_list_header(slist, xx, yy, w, h, filter, name))
		return select

	searchcleared = slist.search_changed && !slist.search
	searchfocused = (window_focus = string(slist.search_tbx))
	searchunfocused = slist.search_focused && !searchfocused
	slist.search_focused = searchfocused

	h -= list_header_height
	yy += list_header_height
	
	if (h < headerh)
		return select
	
	headermouseon = (app_mouse_box(xx, yy, w, headerh) && content_mouseon)
	
	if (!slist.header_show)
	{
		slist.column_x[0] = 0
		slist.column_w[0] = w
		h -= 4
	}
	else
	{
		// Dragging
		if (window_busy = "sortlist/resize" && sortlist_resize = slist)
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
			if (c > 0 && app_mouse_box(xx + dx - 5, yy, 10, headerh) && content_mouseon)
			{
				mouse_cursor = cr_size_we
				if (mouse_left_pressed)
				{
					sortlist_resize = slist
					sortlist_resize_column = c
					sortlist_resize_column_x = slist.column_x[c]
					window_busy = "sortlist/resize"
				}
			}
			
			// Button
			icon = null
			if (slist.column_sort = c)
				icon = (slist.sort_asc ? icons.SORT_UP : icons.SORT_DOWN)
			
			if (sortlist_draw_button("column/" + slist.column_name[c], xx + dx, yy + 3, slist.column_w[c], headerh - 6, slist.column_sort = c, icon, (c = 0), (c = slist.columns - 1), headermouseon))
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
				
				sortchanged = true
				sortlist_update(slist)
			}
		}
	}
	
	// Items
	dy = yy + headerh
	
	// Background
	draw_box(xx, yy + headerh, w, h - headerh, false, c_input_background, 1)
	
	if (slist.header_show)
		draw_divide(xx + 1, dy, w - 2)

	listy = dy
	listhei = yy + h - listy
	if (listhei <= 0)
		return select
	
	slist.view_height = listhei
	slist.items_visible = max(1, floor(listhei / itemh))
	
	if (slist.view_value != null)
	{
		var viewvalue = slist.view_value;
		sortlist_view(slist, viewvalue, false)
		slist.view_value = null
	}

	if ((searchunfocused && slist.search || searchcleared || sortchanged) && select != null)
	{
		var scrollvalue = slist.scroll.value;
		if (sortlist_view(slist, select, true, max(1, floor(listhei / itemh))))
			slist.scroll.value = clamp(scrollvalue, slist.scroll.value_goal - list_center_max, slist.scroll.value_goal + list_center_max)
	}
	
	if (slist.center_on_draw && (!ispicker || !slist.grid_view))
	{
		var centerindex = ds_list_find_index(slist.display_list, select);
		if (centerindex >= 0)
		{
			slist.scroll.value = max(0, centerindex - floor(slist.items_visible / 2)) * itemh
			slist.scroll.value_goal = slist.scroll.value
		}
		slist.center_on_draw = false
	}

	scrolloffset = slist.scroll.value mod itemh
	dy -= scrolloffset
	
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
	
	var clipactive, clipx, clipy, clipwid, cliphei;
	clipactive = shader_clip_active
	if (clipactive)
	{
		clipx = shader_clip_x
		clipy = shader_clip_y
		clipwid = shader_clip_width
		cliphei = shader_clip_height
	}
	clip_begin(xx, listy, w - 12 * slist.scroll.needed, listhei)

	if (slist.header_show)
		dy += 3
	else
		dy += 5
	
	// Column layout is shared by all visible rows
	var columnx, columnwidth, dw;
	columnx = array_create(slist.columns)
	columnwidth = array_create(slist.columns)
	dw = w - 12 * slist.scroll.needed

	for (var c = 0; c < slist.columns; c++)
	{
		columnx[@c] = xx + floor(slist.column_x[c] * w) + 8
		columnwidth[@c] = slist.column_w[c] - 8
		if (c = slist.columns - 1 && slist.scroll.needed)
			columnwidth[@c] -= 12
	}

	for (var i = floor(slist.scroll.value / itemh); i < ds_list_size(slist.display_list); i++)
	{
		if (dy >= yy + h)
			break
		
		var value, selected, mouseon, visibley, visiblehei;
		value = slist.display_list[|i]
		selected = (select = value)
		visibley = max(dy, listy)
		visiblehei = min(dy + itemh, yy + h) - visibley
		mouseon = (visiblehei > 0 && app_mouse_box(xx, visibley, dw, visiblehei) && content_mouseon)
		
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
			dx = columnx[c]
			wid = columnwidth[c]
			
			islast = (c = slist.columns - 1) && (c != 0)
			
			/*
			if (slist.columns = 1 && selected)
			{
				draw_image(spr_icons, icons.TICK, xx + dw - 16, dy + itemh/2, 1, 1, c_accent, 1)
				wid -= 32
			}
			*/
			
			text = string_limit(string(sortlist_column_get(slist, value, c)), wid)
			draw_label(text, dx + ((wid - 8) * islast), floor(dy + itemh / 2), islast ? fa_right : fa_left, fa_middle, selected ? c_accent : c_text_main, selected ? 1 : a_text_main)
		}
		
		if (mouseon && slist.script != null)
		{
			mouse_cursor = cr_handpoint
			if (mouse_left_released)
			{
				var vars = null;
				if (ispicker)
				{
					var asset, search;
					if (is_array(value))
						asset = value[0] ? mc_assets.model_name_map[?value[1]] : mc_assets.block_name_map[?value[1]]
					else
						asset = slist.asset_picker_model ? mc_assets.model_name_map[?value] : mc_assets.block_name_map[?value]

					search = string_lower(slist.search_tbx.text)
					vars = asset_picker_get_state(asset, search)
					if (selected && is_array(state) && search = "")
						vars = minecraft_asset_get_state(asset, state)
				}

				if (selected && window_focus = string(slist.scroll) && slist.script_select_click != null)
				{
					if (ispicker)
						script_execute(slist.script, value, vars)
					script_execute(slist.script_select_click)
					if (slist.script_select_click = action_bench_create)
						bench_show_ani_type = "hide"
				}
				else if (slist.can_deselect && selected)
				{
					script_execute(slist.script, null)
					if (ispicker)
						select = null
				}
				else if (ispicker)
				{
					script_execute(slist.script, value, vars)
					select = value
				}
				else
					script_execute(slist.script, value)
				app_mouse_clear()
				
				window_focus = string(slist.scroll)
			}
		}
		
		dy += itemh
	}
	
	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
	
	// Scrollbar
	slist.scroll.snap_value = 0
	slist.scroll.wheel_speed = itemh * 4
	scrollbar_draw(slist.scroll, e_scroll.VERTICAL, xx + w - 12, listy, listhei, ds_list_size(slist.display_list) * itemh + 8)
	return select
}
