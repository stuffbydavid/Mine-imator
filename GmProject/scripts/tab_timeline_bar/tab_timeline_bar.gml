/// tab_timeline_bar(barx, bary, barw, barh, headerh, listw, tlx, tly, tlw, tlh, itemh, markerh, mouseinnames)

function tab_timeline_bar(barx, bary, barw, barh, headerh, listw, tlx, tly, tlw, tlh, itemh, markerh, mouseinnames)
{
	timeline_region_x1 = 0
	timeline_region_x2 = 0

	// Timeline bar
	draw_box(barx, bary, barw, barh, false, c_level_bottom, 1)
	
	// Timeline region
	if (timeline_region_start != null)
	{
		timeline_region_x1 = floor(timeline_region_start * timeline_zoom - timeline.hor_scroll.value)
		timeline_region_x2 = floor(timeline_region_end * timeline_zoom - timeline.hor_scroll.value)
		
		var x1, x2;
		x1 = clamp(timeline_region_x1, 0, barw)
		x2 = clamp(timeline_region_x2, 0, barw)
			
		// Highlight bar area
		draw_box(barx + x1, bary, x2 - x1, barh, false, c_accent_overlay, a_accent_overlay)
			
		// Darken left
		draw_box(barx, bary, x1, markerh + barh, false, c_black, a_dark_overlay)
			
		// Darken right
		draw_box(barx + x2, bary, (barx + barw) - (barx + x2), markerh + barh, false, c_black, a_dark_overlay)
			
		x1 = timeline_region_x1
		x2 = timeline_region_x2
			
		// Start/end markers
		if (x1 >= -32 && x1 <= (barw + 32))
		{
			draw_image(spr_marker_region, timeline_region_start <= 0 ? 1 : 0, barx + x1 + (timeline_region_start <= 0 ? 10 : 0), bary, 1, 1, c_accent, 1)
			draw_box(barx + x1, bary, 1, markerh + barh, false, c_accent, 1)
		}
			
		if (x2 >= -32 && x2 <= (barw + 32))
		{
			draw_image(spr_marker_region, 1, barx + x2 + 10, bary, 1, 1, c_accent, 1)
			draw_box(barx + x2, bary, 1, markerh + barh, false, c_accent, 1)
		}
	}
	
	// Frames
	var framestep, framehighlight, f;
	framestep = 1
	framehighlight = 5
	
	if (timeline_zoom < 0.5)
	{
		framestep = 50
		framehighlight = 200
	}
	else if (timeline_zoom < 1)
	{
		framestep = 20
		framehighlight = 100
	}
	else if (timeline_zoom < 3)
	{
		framestep = 10
		framehighlight = 50
	}
	else if (timeline_zoom < 5)
	{
		framestep = 5
		framehighlight = 10
	}
	
	f = floor(timeline.hor_scroll.value / (timeline_zoom * framestep)) * framestep
	
	draw_set_valign(fa_bottom)
	draw_set_font(font_subheading)
	
	for (dx = 1 - (timeline.hor_scroll.value mod (timeline_zoom * framestep)); dx < barw; dx += timeline_zoom * framestep)
	{
		var highlight, linex, color, linecolor, linealpha, alpha, fullsec, halfsec, inregion;
		highlight = ((f mod framehighlight) = 0)
		linex = floor(barx + dx)
		alpha = 1
		fullsec = false
		halfsec = false
		inregion = false
		
		color = c_text_secondary
		alpha = a_text_secondary
		linecolor = c_text_main
		linealpha = a_text_main
		
		// Frame highlight
		if (project_file != "" && instance_exists(obj_timeline) && timeline_intervals_show)
		{
			if (((timeline_interval_offset - f) mod timeline_interval_size) = 0 && f > 0)
			{
				color = c_accent
				alpha = 1
				
				linecolor = c_accent
				linealpha = .5
				
				draw_line_ext(linex, tly, linex, tly + min(tlh, max(0, ds_list_size(tree_visible_list) * itemh - timeline.ver_scroll.value)), linecolor, linealpha)
			}
		}
		
		// Vertical notch in timeline bar
		draw_line_ext(linex, (bary + barh - (highlight ? 6 : 3)), linex, bary + barh, linecolor, linealpha)
		
		if (highlight)
		{
			var oldcol = draw_get_color();
			var oldalpha = draw_get_alpha();
			
			draw_set_color(color)
			draw_set_alpha(alpha * oldalpha)
			draw_set_halign((f = 0) ? fa_left : fa_center)
			
			draw_text(linex, bary + barh - 8, string(f))
			
			draw_set_halign(fa_left)
			draw_set_color(oldcol)
			draw_set_alpha(oldalpha)
		}
		
		f += framestep
	}
	
	content_mouseon = true
	
	// Bar
	if (app_mouse_box(barx, bary + 5 * (tab.panel = panel_map[?"bottom"]), barw, barh - 5 * (tab.panel = panel_map[?"bottom"]), "place") && !popup_mouseon && !context_menu_mouseon && !toast_mouseon)
	{
		mouse_cursor = cr_handpoint
		
		// Change region
		if (timeline_region_start != null)
		{
			if (app_mouse_box(barx + timeline_region_x1 + (timeline_region_start <= 0 ? 0 : -8), bary, 8, barh, "place"))
			{
				mouse_cursor = cr_size_we
				if (mouse_left_pressed)
				{
					window_focus = "timeline"
					window_busy = "timelinesetregionstart"
					timeline_region_pos = timeline_region_end
				}
			}
			else if (app_mouse_box(barx + timeline_region_x2, bary, 8, barh, "place"))
			{
				mouse_cursor = cr_size_we
				if (mouse_left_pressed)
				{
					window_focus = "timeline"
					window_busy = "timelinesetregionend"
					timeline_region_pos = timeline_region_start
				}
			}
		}
		
		// Move marker
		if (mouse_left_pressed && window_busy = "")
		{
			window_focus = "timeline"
			window_busy = "timelinemarker"
		}
		
		// Create region
		if (mouse_right_pressed)
		{
			window_focus = "timeline"
			window_busy = "timelinecreateregion"
			timeline_region_pos = timeline_mouse_pos
			action_tl_play_break()
		}
	}
	
	// Set region
	if (window_busy = "timelinecreateregion" || window_busy = "timelinesetregionstart" || window_busy = "timelinesetregionend")
	{
		var release;
		
		if (window_busy = "timelinecreateregion")
		{
			mouse_cursor = cr_handpoint
			release = !mouse_right
		}
		else
		{
			mouse_cursor = cr_size_we
			release = !mouse_left
		}
		
		project_changed = true
		
		if (window_busy = "timelinesetregionend")
		{
			if (timeline_mouse_pos >= timeline_region_pos)
			{
				timeline_region_start = timeline_region_pos
				timeline_region_end = timeline_mouse_pos
			}
			else
			{
				timeline_region_end = timeline_region_pos
				timeline_region_start = timeline_mouse_pos
			}
		}
		else
		{
			if (timeline_mouse_pos >= timeline_region_pos)
			{
				timeline_region_start = timeline_region_pos
				timeline_region_end = timeline_mouse_pos
			}
			else
			{
				timeline_region_end = timeline_region_pos
				timeline_region_start = timeline_mouse_pos
			}
		}
		
		if (release)
		{
			if (timeline_region_start = timeline_region_end)
			{
				timeline_region_start = null
				timeline_region_end = null
			}
			window_busy = ""
		}
	}
	
	// Move marker
	if (window_busy = "timelinemarker")
	{
		mouse_cursor = cr_handpoint
		timeline_marker = max((timeline.hor_scroll.value + mouse_x - barx) / timeline_zoom, 0)
		
		if (setting_timeline_frame_snap || keyboard_check(vk_control))
			timeline_marker = round(timeline_marker)
		
		if (!mouse_left)
		{
			window_busy = ""
			timeline_marker = round(timeline_marker)
			
			action_tl_play_jump()
			app_mouse_clear()
		}
	}
	
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	// Auto scroll
	var verscrollspeed, horscrollspeed;
	verscrollspeed = 8
	horscrollspeed = 15
	
	// Move view when selecting
	if (window_busy = "timelinemove" || window_busy = "timelineselect" || (window_busy = "place" && mouseinnames))
	{
		if (mouse_y < tly + 6)
			timeline.ver_scroll.value -= verscrollspeed
		if (mouse_y > tly + tlh - 6)
			timeline.ver_scroll.value += verscrollspeed
		
		timeline.ver_scroll.value = max(0, timeline.ver_scroll.value)
		timeline.ver_scroll.value_goal = timeline.ver_scroll.value
	}
	
	
	// Move view when selecting/moving keyframes
	if (window_busy = "timelineselectkeyframes" || 
		window_busy = "timelinemovekeyframes" || 
		window_busy = "timelinecreateregion" || 
		window_busy = "timelinesetregionstart" || 
		window_busy = "timelinesetregionend" || 
		window_busy = "timelineresizesounds" || 
		window_busy = "timelinesetsoundend" ||
		window_busy = "timelinemovemarker"
	)
	{
		if (mouse_x < tlx) // no padding needed here
			timeline.hor_scroll.value -= horscrollspeed
		if (mouse_x > tlx + tlw - 6)
			timeline.hor_scroll.value += horscrollspeed
		
		if (window_busy != "timelinemovemarker" &&
			window_busy != "timelinecreateregion" && 
			window_busy != "timelinesetregionstart" &&
			window_busy != "timelinesetregionend"
		)
		{
			if (mouse_y < tly + 6)
				timeline.ver_scroll.value -= verscrollspeed
			if (mouse_y > tly + tlh - 6)
				timeline.ver_scroll.value += verscrollspeed
		}
		
		timeline.ver_scroll.value = max(0, timeline.ver_scroll.value)
		timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
		
		timeline.ver_scroll.value_goal = timeline.ver_scroll.value
		timeline.hor_scroll.value_goal = timeline.hor_scroll.value
	}

	// Zoom
	if (timeline_zoom_button <> 0 || (window_scroll_focus_prev = "timelinezoom" && window_busy = "" && mouse_wheel <> 0))
	{
		var m;
		if (timeline_zoom_button <> 0)
			m = (timeline_zoom_button = 1 ? .5 : 2)
		else
			m = (mouse_wheel = 1 ? .5 : 2)
		timeline_zoom_goal = clamp(timeline_zoom_goal * m, 0.25, 32)
		if (timeline_zoom_goal > 1)
			timeline_zoom_goal = round(timeline_zoom_goal)
		if (timeline_zoom_button <> 0)
			timeline_zoom_target =  (barw * .5) + barx
		else
		 	timeline_zoom_target = mouse_x
	}
	
	var zoompoint = (timeline_zoom_target - barx + timeline.hor_scroll.value);
	if (timeline_zoom != timeline_zoom_goal)
	{
		if (setting_timeline_autoscroll && timeline_playing)
			zoompoint = (timeline_marker * timeline_zoom)
		
		timeline.hor_scroll.value_goal = min(
			max( // Prevent zooming into timeline past the furthest of these points
				(timeline_length * timeline_zoom_goal), // End of animation
				(timeline_marker * timeline_zoom_goal), // Playhead
				(ds_list_size(timeline_marker_list) > 0 ? (timeline_marker_list[|ds_list_size(timeline_marker_list) - 1].pos * timeline_zoom_goal) : null) // Last timeline marker if any exist
			),
			// Convert current and new mouse position to frames, then get difference and add it
			round(timeline.hor_scroll.value + ((zoompoint / timeline_zoom) - (zoompoint / timeline_zoom_goal)) * timeline_zoom_goal)
		)
	}
	
	// Horizontal scrollbar
	if (content_height > (barh + headerh + 12) && (!timeline_playing || !setting_timeline_autoscroll))
	{
		if (timeline.hor_scroll.needed)
			draw_box(tlx, content_y + content_height - 12, content_width - listw, 12, false, c_level_middle, 1)
		
		scrollbar_draw(timeline.hor_scroll, e_scroll.HORIZONTAL, tlx, content_y + content_height - 12, tlw, floor(max(timeline_length, timeline_marker, timeline_marker_length) * timeline_zoom + tlw))
	}
}
