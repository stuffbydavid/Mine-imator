/// tab_timeline()

function tab_timeline()
{
	var itemh, tlx, tly, tlw, tlh, tlstartpos;
	var listx, listy, listw, listh;
	var headerx, headery, headerw, headerh;
	var barx, bary, barw, barh;
	var markerbarshow, markerbarx, markerbary, markerbarw, markerbarh, markerh;
	var show_hor_scroll, mouseinmarkers, mouseintl, mouseinnames, mouseinbar, mousetl, listviewh;

	if (place_tl != null && app_mouse_box(content_x, content_y, content_width, content_height, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
		place_content_mouseon = "timeline"
	
	markerbarshow = (ds_list_size(timeline_marker_list) > 0) && setting_timeline_show_markers
	
	// Background
	draw_box(content_x, content_y, content_width, content_height, false, c_level_middle, 1)
	draw_divide(content_x, content_y + 1, content_width)
	
	// Init
	itemh = setting_timeline_compact ? 20 : 24
	
	// Header
	headerw = content_width
	headerh = 32
	headerx = content_x
	headery = content_y
	
	// Bar
	barw = content_width - tab.list_width
	barh = 32
	barx = content_x + min(timeline.list_width, content_width)
	bary = content_y + headerh
	
	// List
	listx = content_x
	listy = content_y + (headerh + barh)
	listw = min(timeline.list_width, content_width)
	listh = (content_height - (headerh + barh) - (12 * timeline.hor_scroll_tl.needed) - (32 * !setting_timeline_compact))
	
	// Timeline
	show_hor_scroll = (timeline.hor_scroll.needed && !(timeline_playing && setting_timeline_autoscroll))
	
	tlx = content_x + listw
	tly = content_y + (headerh + barh)
	tlw = content_width - (12 * timeline.ver_scroll.needed) - listw
	tlh = (content_height - (headerh + barh) - ((12 * show_hor_scroll)))
	
	// Marker bar
	markerbarx = tlx
	markerbary = (content_y + content_height) - ((12 * show_hor_scroll) + 24)
	markerbarw = tlw
	markerbarh = 24
	
	if (markerbary <= tly || !markerbarshow)
	{
		markerbary += markerbarh
		markerbarh = 0
	}
	
	markerh = max(0, markerbary - tly)
	listviewh = setting_timeline_compact ? tlh : min(tlh, listh)
	
	// Adjust by panel location
	if (tab.panel = panel_map[?"left"] || tab.panel = panel_map[?"left_secondary"])
		tlw -= 5
	else if (tab.panel = panel_map[?"right"] || tab.panel = panel_map[?"right_secondary"])
	{
		listx += 5
		listw -= 5
	}
	
	// Pan before drawing the timeline rows
	if (window_busy = "timelinedrag")
	{
		mouse_cursor = cr_size_all
		timeline.hor_scroll.value = clamp(timeline.hor_scroll.value - mouse_dx, 0, floor(max(timeline_length, timeline_marker, timeline_marker_length) * timeline_zoom))
		timeline.ver_scroll.value = clamp(timeline.ver_scroll.value - mouse_dy, 0, max(0, (ds_list_size(tree_visible_list) + 1) * itemh - listviewh))

		if (!mouse_middle)
		{
			timeline.hor_scroll.value = snap(timeline.hor_scroll.value, timeline.hor_scroll.snap_value)
			timeline.ver_scroll.value = snap(timeline.ver_scroll.value, timeline.ver_scroll.snap_value)
			window_busy = ""
		}

		timeline.hor_scroll.value_goal = timeline.hor_scroll.value
		timeline.ver_scroll.value_goal = timeline.ver_scroll.value
	}

	timeline_list_first = floor(timeline.ver_scroll.value / itemh)
	timeline_list_visible = floor(listviewh / itemh)
	
	tlstartpos = timeline.hor_scroll.value / timeline_zoom
	if (timeline_marker < tlstartpos || timeline_marker > tlstartpos + tlw / timeline_zoom)
		timeline_insert_pos = tlstartpos
	else
		timeline_insert_pos = timeline_marker
	
	// Mouse
	mouseinmarkers = (app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseintl = (app_mouse_box(tlx, tly, tlw, tlh, "place") && !mouseinmarkers && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseinnames = (app_mouse_box(listx, listy, listw - 5, listh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseinbar = (app_mouse_box(barx, bary, barw, barh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mousetl = floor((mouse_y - tly + floor(timeline.ver_scroll.value)) / itemh)
	if (mousetl >= 0 && mousetl < ds_list_size(tree_visible_list))
		mousetl = tree_visible_list[|mousetl]
	else
		mousetl = null
	
	timeline_mouse_pos = max(0, round((mouse_x - tlx + timeline.hor_scroll.value) / timeline_zoom))
	timeline_zoom_button = 0
	
	// Header
	tab_timeline_header(headerx, headery, headerw, headerh, listw)
	
	// Background
	tab_timeline_background(tlx, tly, tlw, tlh, itemh, mouseinnames, mousetl)
	
	// Timeline bar
	content_mouseon = app_mouse_box(barx, bary, barw, barh, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	tab_timeline_bar(barx, bary, barw, barh, headerh, listw, tlx, tly, tlw, tlh, itemh, markerh, mouseinnames)
	
	// Keyframes
	tab_timeline_keyframes(tlx, tly, tlw, tlh, itemh, tlstartpos, mouseintl, mousetl)
	
	// Markers
	tab_timeline_markers(tlx, tly, tlw, bary, barh, barw, markerh, markerbarx, markerbary, markerbarw, markerbarh)
	
	// List
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height, "place") && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	tab_timeline_list(listx, listy, listw, listh, tlx, tly, tlw, tlh, bary, barh, headerh, itemh, mouseinnames, mousetl)
	
	// Update shortcut bar
	if (content_mouseon)
	{
		shortcut_bar_state = "timeline"
		
		if (mouseintl)
			shortcut_bar_state = "timelinekeyframes"
		
		if (mouseinnames)
			shortcut_bar_state = "timelinenames"
		
		if (mouseinbar)
			shortcut_bar_state = "timelinebar"
		
		if (window_busy = "timelinescalekeyframes")
			shortcut_bar_state = "timelinescale"
		
		window_scroll_focus = string(timeline.ver_scroll)
		
		if (keyboard_check(vk_shift))
		{
			if (mouseinnames)
				window_scroll_focus = string(timeline.hor_scroll_tl)
			else
				window_scroll_focus = string(timeline.hor_scroll)
		}
		
		if (keyboard_check(vk_control))
			window_scroll_focus = "timelinezoom"
	}
}
