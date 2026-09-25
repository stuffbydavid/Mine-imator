/// tab_timeline_list(listx, listy, listw, listh, tlx, tly, tlw, tlh, bary, barh, headerh, itemh, mouseinnames, mousetl)

function tab_timeline_list(listx, listy, listw, listh, tlx, tly, tlw, tlh, bary, barh, headerh, itemh, mouseinnames, mousetl)
{
	var buttonsize, buttonpad, searchx, searchwid, itemmaxw, tlmaxw, indent, tlhierarchy;
	var mousetlname, mousemovetl, mousemoveindex, movehltl, movehlpos;
	indent = 20
	tlhierarchy = (timeline_search = "")
	
	mousetlname = null
	mousemovetl = null
	mousemoveindex = null
	movehltl = null
	movehlpos = null

	// Timeline list
	buttonsize = 16
	buttonpad = (itemh - buttonsize)/2
	
	draw_box(content_x, bary, listw, content_height - headerh, false, c_level_middle, 1)
	draw_divide_vertical(content_x + listw, tly - barh, content_height - headerh)
	draw_divide(content_x, bary, listw)
	
	// Filter (advanced mode only)
	if (setting_advanced_mode)
	{
		if (draw_button_icon("timelinefilter", listx + 8, bary + 4, 24, 24,
			setting_timeline_hide_structure_blocks || setting_timeline_hide_nonanimated ||setting_timeline_hide_ghosts || 
			!array_equals(timeline_hide_color_tag, array_create(array_length(timeline_hide_color_tag), false)),
			icons.FILTER, null, false, "tooltiptlfilter"))
		{
			menu_settings_set(listx + 8, bary + 4, "timelinefilter", 24)
			settings_menu_script = tl_filter_draw
			settings_menu_above = true
		}
	
		if (settings_menu_name = "timelinefilter" && settings_menu_ani_type != "hide")
			current_microani.active.value = true
	}
	
	// Draw search bar
	searchx = (setting_advanced_mode ? listx + (24 + 16) : listx + 8) 
	searchwid = (setting_advanced_mode ? listw - (24 + 24) : listw - 16) 
	timeline.tbx_search.text = timeline_search
	draw_textfield("timelinesearch", searchx, bary + 4, searchwid, 24, timeline.tbx_search, action_tl_search, text_get("listsearch"), "none")
	
	// Context menu
	if (mouseinnames)
		context_menu_area(listx, listy, listw, listh, "timelinelist", mousetl, null, null, null)
	
	var rowmouseon = content_mouseon;
	content_mouseon = mouseinnames
	if (listw > 0 && listh > 0)
		clip_begin(listx, listy, listw, listh)

	dy = listy - (floor(timeline.ver_scroll.value) - timeline_list_first * itemh)
	
	tlmaxw = 0
	
	for (var t = timeline_list_first; listw > 0 && listh > 0 && t < ds_list_size(tree_visible_list); t++)
	{
		if (dy > listy + listh)
			break
		
		var tl, itemx, itemy, itemw, itemhover, buttonhover, minw, xx, xright;
		tl = tree_visible_list[|t]
		itemx = (content_x + (indent * tl.indent_level)) - timeline.hor_scroll_tl.value
		itemy = dy
		itemw = listw - 8 - (indent * tl.indent_level) + timeline.hor_scroll_tl.value
		itemhover = (tl = mousetl) && mouseinnames
		buttonhover = false
		
		itemmaxw = (indent * tl.indent_level) + 32
		
		// Hovering
		if (itemhover)
			mouse_cursor = cr_handpoint
			
		// Parent hovering item to selected timeline
		if (itemhover && mouse_left_released && place_tl != null && place_tl != tl)
		{
			with (place_history)
			{
				parent = tl
				tl_value_set_vec3(e_value.POS_X, vec3(0), true)
			}
			
			with (place_tl)
			{
				tl_value_set_vec3(e_value.POS_X, vec3(0))
				tl_value_set_vec3(e_value.POS_X, vec3(0), true)
				tl_set_parent(tl)
			}
				
			tl_update_list()
			tl_update_matrix()
			render_samples = -1
			app_stop_place(true)
		}
		
		if ((itemhover && mouse_left) || tl.selected)
			draw_box(content_x, itemy, listw, itemh, false, c_accent_overlay, a_accent_overlay)
		else if (itemhover || tl = context_menu_value || (window_busy = "timelineclick" && timeline_select = tl))
			draw_box(content_x, itemy, listw, itemh, false, c_overlay, a_overlay)
		
		xx = itemx + itemw - ((buttonsize + 4) * (itemhover || tl.hide || tl.lock || (!setting_timeline_hide_ghosts && tl.ghost)))
		
		// Hide/mute
		if (itemhover || tl.hide)
		{
			if (tl.type != e_tl_type.AUDIO_TRACK)
			{
				// Hide
				if (draw_button_icon("timelinehide" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.hide, tl.hide ? icons.HIDDEN_SMALL : icons.VISIBLE_SMALL, null, false, tl.hide ? "tooltiptlshow" : "tooltiptlhide"))
					action_tl_hide(tl)
			}
			else
			{
				// Mute
				if (draw_button_icon("timelinehide" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.hide, tl.hide ? icons.MUTE_SMALL : icons.VOLUME_SMALL, null, false, tl.hide ? "tooltiptlunmute" : "tooltiptlmute"))
					action_tl_hide(tl)
			}
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize, "place")
		}
		xx -= (buttonsize + 4) * (itemhover || tl.lock || (!setting_timeline_hide_ghosts && tl.ghost))
		itemmaxw += buttonsize + buttonpad
		
		// Lock
		if (itemhover || tl.lock)
		{
			if (draw_button_icon("timelinelock" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.lock, tl.lock ? icons.LOCK_SMALL : icons.UNLOCK_SMALL, null, false, (tl.lock ? "tooltiptlunlock" : "tooltiptllock")))
				action_tl_lock(tl)
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize, "place")
		}
		itemmaxw += buttonsize + buttonpad
		
		// Ghost toggle (Advanced mode only)
		if (!setting_timeline_hide_ghosts && setting_advanced_mode)
		{
			xx -= (buttonsize + 4) * (itemhover || tl.ghost)
			
			if (itemhover || tl.ghost)
			{
				if (draw_button_icon("timelineghosttl" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.ghost, icons.GHOST_SMALL, null, false, (tl.ghost ? "tooltiptlunghost" : "tooltiptlghost")))
					action_tl_ghost(tl)
				
				buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize, "place")
			}
		}
		itemmaxw += buttonsize + buttonpad
		
		// Select all keyframes
		xx -= (buttonsize + 4) * itemhover
		
		if (itemhover)
		{
			if (draw_button_icon("timelineselectkeyframes" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, false, icons.KEYFRAME_SMALL, null, false, "contextmenutlselectkeyframes"))
				action_tl_select_keyframes(tl)
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize, "place")
		}
		
		itemmaxw += buttonsize + buttonpad
		
		minw = xx - itemx
		xright = xx
		
		xx = itemx + 4
		minw -= 4
		
		// Hierarchy connections (If hierarchy is possible)
		if (tlhierarchy)
		{
			var connectx, index;
			connectx = content_x + 4 - timeline.hor_scroll_tl.value
			index = null
			
			for (var i = 0; i < array_length(tl.level_display); i++)
			{
				if (tl.level_display[i] && (((connectx + 24) - xright) < max(0, minw)))
				{
					if (i = (tl.indent_level - 1))
					{
						if (tl.parent != app && tl.parent_filter.tree_list_filter[|ds_list_size(tl.parent_filter.tree_list_filter) - 1] = tl)
							index = 2
						else
							index = 1
					}
					else
						index = 0
					
					draw_image(!setting_timeline_compact ? spr_connect : spr_connect_compact, index, connectx, itemy, 1, 1, c_border, a_border)
				}
				
				connectx += indent
			}
			
			// No tree, extend 
			if (tl.parent_filter != app && !setting_timeline_compact && ds_list_size(tl.tree_list_filter) = 0 && (((connectx + 24 + 8) - xright) < minw))
				draw_image(spr_connect, 3, connectx - 2, itemy, 1, 1, c_border, a_border)
		}
		
		// Extent timeline tree
		if (tlhierarchy)
		{
			if (ds_list_size(tl.tree_list_filter) > 0 && (((xx + buttonsize + 8) - xright) < minw))
			{
				if (draw_button_icon("timelineexpand" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.tree_extend, null, null, false, (tl.tree_extend ? "tooltiptlcollapse" : "tooltiptlexpand"), spr_chevron_ani))
					action_tl_extend(tl)
				
				buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize, "place")
				
				// Only offset x if button is present
				if (setting_timeline_compact)
				{
					xx += (buttonsize + 4)
					minw -= (buttonsize + 4)
				}
			}
			else if (setting_timeline_compact)
			{
				xx += 5
				minw -= 5
			}
			
			// Always offset extend button
			if (!setting_timeline_compact)
			{
				xx += (buttonsize + 4)
				minw -= (buttonsize + 4)
			}
		}
		
		// Timeline icon
		if (!setting_timeline_compact)
		{
			var iconcolor, iconalpha;
			
			if (tl.selected || (window_busy = "timelineclick" && timeline_select = tl) || ((itemhover && !buttonhover) && (mouse_left || mouse_left_released)))
			{
				if (tl.color_tag = null)
					iconcolor = c_accent
				else
					iconcolor = setting_theme.accent_list[tl.color_tag]
				
				iconalpha = 1
			}
			else
			{
				if (tl.color_tag = null)
				{
					iconcolor = c_text_tertiary
					iconalpha = a_text_tertiary
				}
				else
				{
					iconcolor = setting_theme.accent_list[tl.color_tag]
					iconalpha = .75
				}
			}
			
			var list = setting_theme.dark ? timeline_icon_list_dark : timeline_icon_list;
			var licon = list[|tl.type];
			
			// Icon overrides
			if (tl.type = e_tl_type.CAMERA && tl = timeline_camera)
				licon = icons.CAMERA_ACTIVE
			else if (tl.type = e_tl_type.BACKGROUND && tl = background_tlactive)
				licon = icons.CLOUD_ACTIVE
			else if (place_build && tl = build_structure)
			{
				licon = icons.SCENERY_EDIT // Structure editing in build mode
				iconcolor = c_accent
				iconalpha = 1
			}
			
			if (tl.type != null && (((xx + 24) - xright) < minw))
				draw_image(spr_icons, licon, xx + (buttonsize/2), itemy + (itemh/2), 1, 1, iconcolor, iconalpha)
			
			xx += 24
			minw -= 24
			itemmaxw += 24
		}
		
		/*
		// Structure editing in build mode
		xx += 1
		if (place_build && tl = build_structure && minw >= 20)
		{
			draw_image(spr_icons, icons.PENCIL, xx + 8, itemy + (itemh/2), .75, .75, c_accent, 1)
			xx += 22
			minw -= 22
			itemmaxw += 22
		}
		*/
		
		tl.list_mouseon = itemhover && !buttonhover
		
		// Timeline name
		var namecolor, namealpha, name;
		draw_set_font(font_value)
		name = string_limit(tl.display_name, minw)
		
		// Rename textbox
		if (timeline_rename && tl = timeline_rename)
		{
			// Placeholder
			if (tl.name = "")
				draw_label(tl.display_name, xx, itemy + (itemh/2), fa_left, fa_middle, c_text_tertiary, a_text_tertiary, font_value)
			
			if (textbox_draw(timeline.tbx_rename, xx, itemy + (itemh/2) - 8, minw, 20, true))
				action_tl_name_single(timeline.tbx_rename.text)
			
			if (window_focus != string(timeline.tbx_rename))
			{
				window_busy = ""
				timeline_rename = null
				
				// Update search results
				if (timeline_search != "")
					tl_update_list()
			}
		}
		else
		{
			var backalpha;
			
			// Draw name
			if (tl.selected || (window_busy = "timelineclick" && timeline_select = tl) || ((itemhover && !buttonhover) && (mouse_left || mouse_left_released)))
			{
				if (tl.color_tag = null)
					namecolor = c_accent
				else
					namecolor = c_level_middle
				
				namealpha = 1
				backalpha = 1
			}
			else
			{
				if (!tl.animated)
				{
					namecolor = c_text_secondary
					namealpha = a_text_secondary	
				}
				else
				{
					namecolor = c_text_main
					namealpha = a_text_main
				}
				backalpha = .25
			}
			
			if (debug_saveid)
				name += " [" + string(tl.save_id) + "]"
			
			if (name != "")
			{
				if (tl.color_tag != null)
					draw_box_rounded(xx - 4, itemy + itemh/2 - 8, string_width(name) + 8, 16, setting_theme.accent_list[tl.color_tag], backalpha)
				
				draw_label(name, xx, itemy + (itemh/2), fa_left, fa_middle, namecolor, namealpha, font_value)
			}
			
			itemmaxw += string_width(tl.display_name) + 8
		}
		
		if (window_busy = "timelineclick")
		{
			window_busy = ""
			
			// Detect if mouse is on icon or name
			if (app_mouse_box(xx - 28, itemy, string_width(name) + 28, itemh, "place"))
				mousetlname = tl
			
			window_busy = "timelineclick"
		}
		
		// Rename
		if (mouse_left_double_pressed && app_mouse_box(xx, itemy, string_width(name), itemh, "place"))
		{
			window_busy = string(timeline.tbx_rename)
			window_focus = window_busy
			
			timeline.tbx_rename.text = tl.name
			timeline_rename = tl
		}
		
		// Timeline contents
		if (!setting_timeline_compact && !tl.tree_extend && ds_list_size(tl.tree_list_filter) > 0)
		{
			xx += string_width(name) + 16
			minw -= string_width(name) + 16
			
			draw_set_font(font_caption)
			
			// Check contents array and display the icon/amount
			for (var i = 0; i < e_tl_type.amount; i++)
			{
				if (tl.tree_contents[i] = 0)
					continue
				
				var iconwid = 24 + ((string_width(string(tl.tree_contents[i])) + 4) * (tl.tree_contents[i] > 1));
				
				if ((xx + (iconwid + 16) - xright) > minw)
					break
				
				draw_image(spr_icons, timeline_icon_list[|i], xx + 12, itemy + (itemh/2), 1, 1, c_border, a_border)
				
				if (tl.tree_contents[i] > 1)
					draw_label(string(tl.tree_contents[i]), xx + 23, itemy + (itemh/2) + 10, fa_left, fa_bottom, c_text_tertiary, a_text_tertiary)
				
				xx += iconwid
				minw -= iconwid
			}
		}
		
		if (window_busy = "timelinemove")
		{
			// Move highlight
			if (timeline_move_highlight_tl = tl)
			{
				draw_box(content_x, dy, listw, itemh, false, c_hover, a_hover)
			}
			else if (timeline_move_highlight_tl = null)
			{
				if (timeline_move_highlight_pos = t)
					draw_box(content_x, max(tly, dy - 2), listw, 4, false, c_hover, a_hover)
				else if (timeline_move_highlight_pos = t + 1)
					draw_box(content_x, dy + itemh - 2, listw, 4, false, c_hover, a_hover)
			}
			
			// Set move target
			var index = ds_list_find_index(tl.parent_filter.tree_list_filter, tl);
			if ((mouse_y >= dy || t = timeline_list_first) && mouse_y < dy + 8)
			{
				mousemovetl = tl.parent_filter
				mousemoveindex = index
				movehlpos = t
			}
			else if (mouse_y > dy + itemh - 8)
			{
				if (tl.tree_extend && ds_list_size(tl.tree_list_filter) > 0)
				{
					mousemovetl = tl
					mousemoveindex = 0
				}
				else if (tl.parent_filter != app && index = ds_list_size(tl.parent_filter.tree_list_filter) - 1)
				{
					mousemovetl = tl.parent_filter.parent_filter
					mousemoveindex = ds_list_find_index(tl.parent_filter.parent_filter.tree_list_filter, tl.parent_filter) + 1
				}
				else
				{
					mousemovetl = tl.parent_filter
					mousemoveindex = index + 1
				}
				movehlpos = t + 1
			}
			else if (tl = mousetl)
			{
				mousemovetl = tl
				mousemoveindex = null
				movehltl = tl
			}
		}
		
		dy += itemh
		
		tlmaxw = max(itemmaxw, tlmaxw)
	}

	if (listw > 0 && listh > 0)
		clip_end()
	
	content_mouseon = rowmouseon
	
	// Timeline list scrollbar
	if (timeline.hor_scroll_tl.needed)
		draw_box(listx, listy + listh, listw, 12, false, c_level_middle, 1)
	
	scrollbar_draw(timeline.hor_scroll_tl, e_scroll.HORIZONTAL, listx, listy + listh, listw, tlmaxw)
	
	// Timeline actions
	if (!setting_timeline_compact && listh > 0)
	{
		var buttony = content_y + content_height - 28;

		tip_set_keybind(e_keybind.CREATE_FOLDER)
		if (draw_button_icon("timelineaddfolder", listx + 8, buttony, 24, 24, false, icons.FOLDER, null, false, "contextmenutladdfolder"))
			action_tl_folder()

		tip_set_keybind(e_keybind.TIMELINE_DUPLICATE)
		if (draw_button_icon("timelineduplicate", listx + 36, buttony, 24, 24, false, icons.DUPLICATE, null, !timeline_settings, "contextmenutlduplicate"))
		{
			list_item_value = null
			action_tl_duplicate()
		}

		tip_set_keybind(e_keybind.TIMELINE_DELETE)
		if (draw_button_icon("timelinedelete", listx + 64, buttony, 24, 24, false, icons.DELETE, null, !timeline_settings, "contextmenutldelete"))
		{
			list_item_value = null
			action_tl_remove()
		}

		if (draw_button_icon("timelineexport", listx + 92, buttony, 24, 24, false, icons.ASSET_EXPORT, null, !timeline_settings, "contextmenutlexport"))
		{
			list_item_value = null
			object_save()
		}
	}

	// Resize list
	if (app_mouse_box(tlx - 5, tly - barh, 5, content_height - headerh, "place"))
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
		{
			window_busy = "timelinelistresize"
			timeline_list_resize_start = listw
		}
	}
	
	if (window_busy = "timelinelistresize")
	{
		mouse_cursor = cr_size_we
		tab.list_width = clamp(timeline_list_resize_start + (mouse_x - mouse_click_x), 128, content_width)
		if (!mouse_left)
			window_busy = ""
	}
	
	// Click timeline list
	if (window_busy = "" && mouseinnames)
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed && (mousetl = null || mousetl.list_mouseon))
		{
			window_busy = "timelineclick"
			timeline_select = mousetl
			timeline_select_startv = timeline.ver_scroll.value
		}
	}

	// Move timelines
	if (window_busy = "timelinemove")
	{
		mouse_cursor = cr_size_all
		timeline_move_highlight_tl = movehltl
		timeline_move_highlight_pos = movehlpos
		if (!mouse_left)
			action_tl_move_done(mousemovetl, mousemoveindex)
	}
	
	// Drag select timelines
	if (window_busy = "timelineselect")
	{
		mouse_cursor = cr_handpoint
		
		var selecthei, x1, y1, x2, y2;
		selecthei = setting_timeline_compact ? tlh : listh
		x1 = clamp(mouse_click_x, content_x, tlx)
		y1 = clamp(mouse_click_y + (timeline_select_startv - timeline.ver_scroll.value), listy, listy + selecthei)
		x2 = clamp(mouse_x, content_x, tlx)
		y2 = clamp(mouse_y, listy, listy + selecthei)
		
		// Swap x
		if (x2 < x1)
		{
			var swap = x1;
			x1 = x2
			x2 = swap
		}
		x2 -= x1
		
		// Swap y
		if (y2 < y1)
		{
			var swap = y1;
			y1 = y2
			y2 = swap
		}
		y2 -= y1
		
		draw_box_selection(x1, y1, x2, y2)
		
		if (!mouse_left)
		{
			if (ds_list_size(tree_visible_list) > 0)
			{
				var stl, etl, tmp;
				
				stl = (mouse_click_y - listy + timeline_select_startv) / itemh
				etl = (mouse_y - listy + timeline.ver_scroll.value) / itemh
				
				if (stl > etl)
				{
					tmp = stl
					stl = etl
					etl = tmp
				}
				
				if (stl < ds_list_size(tree_visible_list))
				{
					stl = clamp(floor(stl), 0, ds_list_size(tree_visible_list) - 1)
					etl = clamp(floor(etl), 0, ds_list_size(tree_visible_list) - 1)
					action_tl_select_area(stl, etl)
				}
			}
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	// Click name list
	if (window_busy = "timelineclick")
	{
		mouse_cursor = cr_handpoint
		if (mouse_move > 5) // Select
		{
			if (mousetlname && mousetlname.selected && mousetlname.part_of = null && !keyboard_check(vk_shift) && !keyboard_check(vk_control) && tlhierarchy)
				action_tl_move_start()
			else
			{
				if (!keyboard_check(vk_shift) && !keyboard_check(vk_control))
					action_tl_deselect_all()
				window_busy = "timelineselect"
			}
		}
		
		if (!mouse_left)
		{
			if (timeline_select)
			{
				if (timeline_select.selected)
				{
					if (keyboard_check(vk_control))
						action_tl_deselect(timeline_select)
					else
					{
						if (place_build && type_is_structure(timeline_select.type))
							action_build_structure(timeline_select, true)
						
						app_update_tl_edit()
					}
				}
				else
					action_tl_select(timeline_select)
			}
			else
				action_tl_deselect_all()
			
			window_busy = ""
		}
	}
	
	// Vertical scrollbar
	if (tlw > 16)
	{
		if (timeline.ver_scroll.needed)
			draw_box(content_x + content_width - 12, tly, 12, tlh, false, c_level_middle, 1)
		
		timeline.ver_scroll.snap_value = 0
		timeline.ver_scroll.wheel_speed = itemh * 3
		scrollbar_draw(timeline.ver_scroll, e_scroll.VERTICAL, content_x + content_width - 12, tly, tlh, (ds_list_size(tree_visible_list) + 1) * itemh + (!setting_timeline_compact ? max(0, tlh - listh) : 0))
	}
}
