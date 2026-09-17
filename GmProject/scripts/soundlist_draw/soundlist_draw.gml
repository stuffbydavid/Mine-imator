/// soundlist_draw(soundlist, x, y, width, height, name)

function soundlist_draw(slist, xx, yy, w, h, name = "")
{
	var filtershow, searchx, searchw, clearx, itemh, listhei, dy;
	var clipactive, clipx, clipy, clipwid, cliphei;
	var dw, visibley, visiblehei, mouseon, row, selected;

	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
		return 0

	filtershow = (slist.source != "project")
	searchx = xx + (filtershow ? 32 : 0)
	searchw = w - (filtershow ? 32 : 0)
	
	if (filtershow && draw_button_icon("soundfilter" + string(slist), xx, yy, 24, 24, !ds_list_empty(slist.filter_list), icons.FILTER, null, false, "tooltipfilterlist"))
	{
		menu_settings_set(xx, yy, "soundfilter" + string(slist), 24)
		settings_menu_script = soundlist_filters_draw
		settings_menu_soundlist = slist
		settings_menu_h_max = 256
		settings_menu_scroll.value = slist.filter_scroll
		settings_menu_scroll.value_goal = slist.filter_scroll
	}
	
	if (filtershow && settings_menu_name = "soundfilter" + string(slist) && settings_menu_ani_type != "hide")
		current_microani.active.value = true

	if (name != "")
	{
		draw_set_font(font_label)
		draw_label(string_limit(name, w - 176), xx + (filtershow ? 32 : 0), yy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary)
		searchx = xx + w - 144
		searchw = 144
	}

	if (slist.search_tbx.text != "")
	{
		clearx = name != "" ? searchx - 24 : searchx + searchw - 24
		if (name = "")
			searchw -= 28
		if (draw_button_icon("soundsearchclear" + string(slist), clearx, yy, 24, 24, false, icons.CLOSE_SMALL, null, false, "tooltipclearsearch"))
		{
			var scrollvalue = slist.scroll.value;
			slist.search_tbx.text = ""
			slist.search = false
			soundlist_update(slist)
			if (sortlist_center(slist, slist.select))
				slist.scroll.value = clamp(scrollvalue, slist.scroll.value_goal - list_center_max, slist.scroll.value_goal + list_center_max)
		}
	}

	if (draw_textfield("soundsearch" + string(slist), searchx, yy, searchw, 24, slist.search_tbx, null, text_get("listsearch"), "none"))
	{
		var searchactive, scrollvalue;
		searchactive = slist.search
		scrollvalue = slist.scroll.value
		slist.search = slist.search_tbx.text != ""
		slist.scroll.value = 0
		slist.scroll.value_goal = 0
		soundlist_update(slist)
		if (searchactive && !slist.search)
			if (sortlist_center(slist, slist.select))
				slist.scroll.value = clamp(scrollvalue, slist.scroll.value_goal - list_center_max, slist.scroll.value_goal + list_center_max)
	}

	yy += 32
	h -= 32
	itemh = ui_small_height
	listhei = h - 4
	if (listhei <= 0)
		return 0

	draw_box(xx, yy, w, listhei, false, c_input_background, 1)
	if (content_mouseon && mouse_left && app_mouse_box(xx, yy, w - 12 * slist.scroll.needed, listhei))
		window_focus = string(slist.scroll)

	if (window_focus = string(slist.scroll))
	{
		draw_outline(xx, yy, w, listhei, 1, c_accent, 1, true)
		window_scroll_focus = string(slist.scroll)

		if (!app_mouse_box(xx, yy, w, listhei) && content_mouseon && mouse_left && window_busy != "scrollbar")
			window_focus = ""
	}
	else
		draw_outline(xx, yy, w, listhei, 1, c_border, a_border, true)

	dy = yy + 5 - slist.scroll.value mod itemh
	
	clipactive = shader_clip_active
	clipx = shader_clip_x
	clipy = shader_clip_y
	clipwid = shader_clip_width
	cliphei = shader_clip_height
	
	clip_begin(xx, yy, w - 12 * slist.scroll.needed, listhei)
	draw_set_font(font_value)
	for (var i = floor(slist.scroll.value / itemh); i < ds_list_size(slist.display_list); i++)
	{
		if (dy >= yy + listhei)
			break

		dw = w - 12 * slist.scroll.needed
		visibley = max(dy, yy)
		visiblehei = min(dy + itemh, yy + listhei) - visibley
		mouseon = visiblehei > 0 && app_mouse_box(xx, visibley, dw, visiblehei) && content_mouseon
		row = slist.display_list[|i]
		selected = (slist.select != null && row[2] = slist.select[2])
		if (selected || mouseon && mouse_left)
		{
			draw_box(xx, dy, dw, itemh, false, c_accent_overlay, a_accent_overlay)
			if (mouseon && mouse_left)
				draw_box_hover(xx, dy, dw, itemh, 1)
		}
		else if (mouseon)
			draw_box(xx, dy, dw, itemh, false, c_overlay, a_overlay)

		draw_label(string_limit(row[1], dw - 16), xx + 8, floor(dy + itemh / 2), fa_left, fa_middle, selected ? c_accent : c_text_main, selected ? 1 : a_text_main)
		if (mouseon && slist.script != null)
		{
			mouse_cursor = cr_handpoint
			if (mouse_left_released)
			{
				slist.select = row
				script_execute(slist.script, row)
				app_mouse_clear()
				if (slist.scroll.needed)
					window_focus = string(slist.scroll)
			}
		}
		dy += itemh
	}
	
	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)

	slist.scroll.snap_value = 0
	slist.scroll.wheel_speed = itemh * 4
	scrollbar_draw(slist.scroll, e_scroll.VERTICAL, xx + w - 12, yy, listhei, ds_list_size(slist.display_list) * itemh + 8)
}
