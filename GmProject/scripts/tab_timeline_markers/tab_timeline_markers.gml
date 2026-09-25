/// tab_timeline_markers(tlx, tly, tlw, bary, barh, barw, markerh, markerbarx, markerbary, markerbarw, markerbarh)

function tab_timeline_markers(tlx, tly, tlw, bary, barh, barw, markerh, markerbarx, markerbary, markerbarw, markerbarh)
{
	// Marker
	var markerx = floor(timeline_marker * timeline_zoom - timeline.hor_scroll.value);
	
	// Auto scrolling
	if (timeline_playing && setting_timeline_autoscroll && window_busy = "")
	{
		while (markerx < 0)
		{
			timeline.hor_scroll.value -= barw
			markerx = floor(timeline_marker * timeline_zoom - timeline.hor_scroll.value)
		}
		
		while (markerx > barw && barw > 0)
		{
			timeline.hor_scroll.value += barw
			markerx = floor(timeline_marker * timeline_zoom - timeline.hor_scroll.value)
		}
		
		timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
		timeline.hor_scroll.value_goal = timeline.hor_scroll.value
	}
	
	if (markerx >= -32 && markerx < (tlw + 32))
	{
		draw_image(spr_marker_playback, 0, tlx + 1 + markerx, bary + barh, 1, 1, c_accent, 1)
		draw_box(tlx + markerx, bary + barh, 2, markerh, false, c_accent, 1)
	}
	
	if (markerbarh <= 0)
		return 0
	
	// Markers
	var barmouseon, markermouseon, markermouseonx;
	barmouseon = app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh, "place")
	markermouseon = null
	content_mouseon = app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
		
	draw_set_font(font_label)
	draw_set_halign(fa_left)
	draw_set_valign(fa_bottom)
	draw_set_color(c_level_middle)
		
	// Background
	draw_box(markerbarx, markerbary, markerbarw, markerbarh, false, c_level_bottom, 1)
		
	clip_begin(tlx, bary, tlw, ((markerbary + markerbarh) - bary) - 4)
		
	// Draw markers
	for (var i = 0; i < ds_list_size(timeline_marker_list); i++)
	{
		var markx, markeditx, marky, markw, markh, marker, color, name;
		marker = timeline_marker_list[|i]
		color = setting_theme.accent_list[marker.color]
		name = marker.name + (dev_mode_debug_names ? " [" + marker.save_id + "]" : "")
			
		markx = tlx + floor(marker.pos * timeline_zoom - timeline.hor_scroll.value)
		markeditx = tlx + floor(marker.edit_pos * timeline_zoom - timeline.hor_scroll.value)
		marky = markerbary + 4
		markw = max(32, string_width(name) + 8)
		markh = 16
			
		if ((markx > tlx + tlw) || (markx + markw < tlx))
			continue
			
		// Ghost header
		if (marker.edit_pos != null)
			draw_image(spr_marker, 0, markeditx, tly, 1, 1, c_text_tertiary, a_text_tertiary)
			
		// Marker header
		draw_image(spr_marker, 0, markx, tly, 1, 1, color, 1)
			
		// Marker stripe
		for (var j = 0; j < ceil((markerbary - tly) / 32) + 1; j += 1)
		{
			// Ghost
			if (marker.edit_pos != null)
				draw_image(spr_marker_stripe, 0, markeditx, tly + (j * 32), 1, 1, c_text_tertiary, a_text_tertiary)
				
			// Color
			draw_image(spr_marker_stripe, 0, markx, tly + (j * 32), 1, 1, color, a_text_tertiary)	
		}
			
		draw_box(markx, marky, markw, markh, false, color, 1)
		draw_text(markx + 4, marky + 16, name)
			
		if (barmouseon && app_mouse_box(markx, marky, markw, markh, "place"))
		{
			mouse_cursor = cr_size_we
			markermouseon = marker
			markermouseonx = markx
		}
	}
		
	clip_end()
		
	// Mouse on marker
	if (markermouseon != null)
	{
		// Right click
		context_menu_area(markerbarx, markerbary, markerbarw, markerbarh, "timelinemarker", markermouseon, null, null, null)
			
		// Start moving
		if (mouse_left_pressed)
		{
			window_busy = "timelinemovemarker"
			markermouseon.edit_pos = markermouseon.pos
			timeline_marker_edit = markermouseon
			timeline_marker_edit_offset = mouse_x - markermouseonx
		}
	}
		
	if (window_busy = "timelinemovemarker")
	{
		var fail, mousepos;
		fail = false
		mousepos = max(0, round(((mouse_x - timeline_marker_edit_offset) - tlx + timeline.hor_scroll.value) / timeline_zoom))
			
		if (round(mousepos) != timeline_marker_edit.pos)
		{
			timeline_marker_edit.pos = round(mousepos)
			marker_list_sort()
		}
			
		mouse_cursor = cr_size_we
			
		if (mouse_left_released)
		{
			// Check if position is already occupied
			for (var j = 0; j < ds_list_size(timeline_marker_list); j++)
			{
				if (timeline_marker_edit = timeline_marker_list[|j])
					continue
					
				if (timeline_marker_edit.pos = timeline_marker_list[|j].pos)
				{
					fail = true
					break
				}
			}
				
			// Restore old position
			if (fail)
				timeline_marker_edit.pos = timeline_marker_edit.edit_pos
			else // Save action
				action_tl_marker_pos()
				
			window_busy = ""
			timeline_marker_edit.edit_pos = null
			timeline_marker_edit = null
			timeline_marker_edit_offset = 0
			marker_list_sort()
		}
	}
}
