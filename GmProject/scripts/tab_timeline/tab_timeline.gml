/// tab_timeline()

function tab_timeline()
{
	var itemh, itemhalf, indent;
	var tlx, tly, tlw, tlh, tlmaxw, tlstartpos, tlhierarchy;
	var listx, listy, listw, listh;
	var mouseinmarkers, mouseintl, mouseinnames, mouseinbar, mousetl, mousetlname, mousekf, mousekfstart, mousekfend;
	var mousemovetl, mousemoveindex, movehltl, movehlpos;
	var headerx, headery, headerw, headerh;
	var markerbarshow, markerbarx, markerbary, markerbarw, markerbarh, markerh;
	var barx, bary, barw, barh;
	var framestep, framehighlight, f;
	var markerx, markery;
	var regionx1, regionx2;
	var show_hor_scroll;
	
	markerbarshow = (ds_list_size(timeline_marker_list) > 0) && setting_timeline_show_markers
	
	// Background
	draw_box(content_x, content_y, content_width, content_height, false, c_level_middle, 1)
	draw_divide(content_x, content_y + 1, content_width)
	
	// Init
	itemh = setting_timeline_compact ? 20 : 24
	itemhalf = itemh / 2
	indent = 20
	tlhierarchy = (timeline_search = "")
	
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
	listh = (content_height - (headerh + barh) - ((12 * timeline.hor_scroll_tl.needed)))
	
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
	
	// Adjust by panel location
	if (tab.panel = panel_map[?"left"] || tab.panel = panel_map[?"left_secondary"])
		tlw -= 5
	else if (tab.panel = panel_map[?"right"] || tab.panel = panel_map[?"right_secondary"])
	{
		listx += 5
		listw -= 5
	}
	
	tlstartpos = timeline.hor_scroll.value / timeline_zoom
	timeline_list_first = round(timeline.ver_scroll.value / itemh)
	timeline_list_visible = floor(tlh / itemh)
	
	if (timeline_marker < tlstartpos || timeline_marker > tlstartpos + tlw / timeline_zoom)
		timeline_insert_pos = tlstartpos
	else
		timeline_insert_pos = timeline_marker
	
	// Mouse
	mouseinmarkers = (app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseintl = (app_mouse_box(tlx, tly, tlw, tlh) && !mouseinmarkers && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseinnames = (app_mouse_box(listx, listy, listw - 5, listh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mouseinbar = (app_mouse_box(barx, bary, barw, barh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon)
	mousetl = floor((mouse_y - tly + (round(timeline.ver_scroll.value / itemh) * itemh)) / itemh)
	mousetlname = null
	mousekf = null
	mousekfstart = null
	mousekfend = null
	
	if (mousetl >= 0 && mousetl < ds_list_size(tree_visible_list))
		mousetl = tree_visible_list[|mousetl]
	else
		mousetl = null
	
	mousemovetl = null
	mousemoveindex = null
	movehltl = null
	movehlpos = null
	timeline_mouse_pos = max(0, round((mouse_x - tlx + timeline.hor_scroll.value) / timeline_zoom))
	
	// Timeline header
	var timex, timelabel;
	timex = headerx + 8
	content_mouseon = app_mouse_box(headerx, headery, headerw, headerh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	// Current time
	draw_set_font(font_heading)
	timelabel = timeline_show_frames ? text_get("timelineframe", floor(timeline_marker)) : string_time_seconds(timeline_marker / project_tempo)
	draw_label(timelabel, timex, headery + headerh - 6, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	timex += string_width(timelabel)
	
	// Time length
	draw_set_font(font_subheading)
	timelabel = timeline_show_frames ? " / " + string(timeline_length) : " / " + string_time_seconds(timeline_length / project_tempo)
	draw_label(timelabel, timex, headery + headerh - 7, fa_left, fa_bottom, c_text_secondary, a_text_secondary)
	timex += string_width(timelabel)
	
	// Time selected
	if (timeline_region_start != null && (timeline_region_start != timeline_region_end))
	{
		timelabel = " (" + (timeline_show_frames ? string(timeline_region_end - timeline_region_start) : string_time_seconds((timeline_region_end - timeline_region_start) / project_tempo)) + ")"
		draw_label(timelabel, timex, headery + headerh - 7, fa_left, fa_bottom, c_accent, a_accent)
		timex += string_width(timelabel)
	}
	
	timex += 8
	
	var buttonsxstart, buttonsx, buttonsy;
	buttonsxstart = (timeline_settings_w = null ? 0 : floor((headerx + headerw/2) - timeline_settings_w/2))
	buttonsx = max(timex, buttonsxstart)
	buttonsy = headery + 4
	
	// Previous keyframe
	draw_button_icon("timelinepreviouskeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_PREVIOUS, action_tl_keyframe_previous, timeline_playing, "tooltiptlpreviouskeyframe")
	buttonsx += 24 + 6
	
	// Previous frame
	if (draw_button_icon("timelinepreviousframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_PREVIOUS, null, timeline_playing, "tooltiptlpreviousframe"))
		timeline_marker = max(((floor(timeline_marker) != timeline_marker) ? floor(timeline_marker) : timeline_marker - 1), 0)
	
	buttonsx += 24 + 6
	
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	// Stop
	draw_button_icon("timelinestop", buttonsx, buttonsy, 24, 24, false, icons.STOP, action_tl_play_stop, false, "tooltiptlstop")
	buttonsx += 24 + 6
	
	// Play
	tip_set_keybind(e_keybind.PLAY)
	draw_button_icon("timelineplay", buttonsx, buttonsy, 24, 24, false, timeline_playing ? icons.PAUSE : icons.PLAY, action_tl_play, false, timeline_playing ? "tooltiptlpause" : "tooltiptlplay")
	buttonsx += 24 + 6
	
	// Skip to region start and play
	if (draw_button_icon("timelineplayregion", buttonsx, buttonsy, 24, 24, false, icons.PLAY_REGION, null, timeline_region_start = null, "tooltiptlplayregion"))
	{
		timeline_marker = timeline_region_start
		
		if (timeline_playing)
			action_tl_play()
		
		action_tl_play()
	}
	
	buttonsx += 24 + 6
	
	draw_divide_vertical(buttonsx, buttonsy + 2, 20)
	buttonsx += 6
	
	// Next frame
	if (draw_button_icon("timelinenextframe", buttonsx, buttonsy, 24, 24, false, icons.FRAME_NEXT, null, timeline_playing, "tooltiptlnextframe"))
		timeline_marker = ((ceil(timeline_marker) != timeline_marker) ? ceil(timeline_marker) : timeline_marker + 1)
	buttonsx += 24 + 6
	
	// Next keyframe
	draw_button_icon("timelinenextkeyframe", buttonsx, buttonsy, 24, 24, false, icons.KEYFRAME_NEXT, action_tl_keyframe_next, timeline_playing, "tooltiptlnextkeyframe")
	buttonsx += 16 + 6
	
	timeline_settings_w = (buttonsx - buttonsxstart)
	
	buttonsxstart = (timeline_settings_right_w = null ? 0 : real(headerx + headerw - timeline_settings_right_w - 8))
	buttonsx = max(buttonsx, buttonsxstart)
	buttonsxstart = buttonsx
	
	// Run/ Walk cycles for simple mode
	if (!setting_advanced_mode)
	{
		if (draw_button_icon("timelinewalkcycle", buttonsx, buttonsy, 24, 24, false, icons.WALK_CYCLE, null, !file_exists_lib(timeline_settings_walk_fn), "tooltiptlwalk"))
			action_tl_load_loop(timeline_settings_walk_fn)
		
		buttonsx += 24 + 6
		
		if (draw_button_icon("timelineruncycle", buttonsx, buttonsy, 24, 24, false, icons.RUN_CYCLE, null, !file_exists_lib(timeline_settings_run_fn), "tooltiptlrun"))
			action_tl_load_loop(timeline_settings_run_fn)
		
		buttonsx += 24 + 4
		
		draw_divide_vertical(buttonsx, buttonsy, 24)
		
		buttonsx += 4
	}
	
	// Interval settings
	draw_button_icon("timelineintervals", buttonsx, buttonsy, 24, 24, timeline_intervals_show, icons.STOPWATCH, action_tl_intervals_show, false, timeline_intervals_show ? "timelineintervalshide" : "timelineintervalsshow")
	buttonsx += 24
	
	if (draw_button_icon("timelineintervalsettings", buttonsx, buttonsy, 16, 24, settings_menu_name = "timelineintervalsettings", icons.CHEVRON_DOWN_TINY, null, false))
	{
		menu_settings_set(buttonsx, buttonsy, "timelineintervalsettings", 24)
		settings_menu_script = tl_interval_settings_draw
	}
	
	if (settings_menu_name = "timelineintervalsettings" && settings_menu_ani_type != "hide")
		current_microani.active.value = true
	
	buttonsx += 16 + 6
	
	// Loop
	var tooltip;
	
	if (!timeline_repeat && !timeline_seamless_repeat)
		tooltip = "tooltiptlenableloop"
	else if (timeline_repeat && !timeline_seamless_repeat)
		tooltip = "tooltiptlenableseamlessloop"
	else
		tooltip = "tooltiptldisableloop"
	
	draw_button_icon("timelineloop", buttonsx, buttonsy, 24, 24, timeline_repeat || timeline_seamless_repeat, timeline_seamless_repeat ? icons.REPEAT_SEAMLESS : icons.REPEAT, action_tl_play_repeat, false, tooltip)
	
	buttonsx += 24 + 4
	draw_divide_vertical(buttonsx, buttonsy, 24)
	buttonsx += 4
	
	// Pop out/back button
	if (window_get_current() = e_window.MAIN)
	{
		if (draw_button_icon("tabpopout", buttonsx, buttonsy, 24, 24, false, icons.EXTERNAL, null, false, "tooltiptlpopout"))
		{
			panel_tab_list_remove(tab.panel, tab)
			window_create(tab.window, content_x, content_y, content_width, content_height)
		}
	}
	else
	{
		if (draw_button_icon("tabpopback", buttonsx, buttonsy, 24, 24, false, icons.INTERNAL, null, false, "tooltiptlpopin"))
			window_close(tab.window)
	}
	buttonsx += 24
	
	timeline_settings_right_w = (buttonsx - buttonsxstart)
	content_mouseon = app_mouse_box(barx, bary, barw, barh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	// Empty
	if (project_file != "" && !instance_exists(obj_timeline) && content_height > 100 && (ds_list_size(timeline_marker_list) = 0))
	{
		var textwid;
		
		draw_set_font(font_body_big)
		
		textwid = string_width(text_get("timelineempty"))
		
		if (tlw > (textwid + 32))
			draw_label(text_get("timelineempty"), floor(tlx + tlw/2 - textwid/2), floor(tly + tlh/2), fa_left, fa_middle, c_text_secondary, a_text_secondary)
	}
	
	// Keyframe backgrounds
	dy = tly
	for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
	{
		if (dy > tly + tlh)
			break
		
		dx = tlx
		var tl = tree_visible_list[|t];
		
		draw_divide(dx, dy + itemh, tlw)
		
		// Select highlight
		if (tl.selected || tl.list_mouseon)
			draw_box(dx, dy, tlw, itemh, false, c_accent_overlay, a_accent_overlay)
		
		// Hidden
		if (tl.hide)
			draw_box(dx, dy, tlw, itemh, false, c_level_bottom, .5)
		
		dy += itemh
	}
	
	// Timeline bar
	draw_box(barx, bary, barw, barh, false, c_level_bottom, 1)
	
	// Timeline region
	if (timeline_region_start != null)
	{
		regionx1 = floor(timeline_region_start * timeline_zoom - timeline.hor_scroll.value)
		regionx2 = floor(timeline_region_end * timeline_zoom - timeline.hor_scroll.value)
		
		var x1, x2;
		x1 = clamp(regionx1, 0, barw)
		x2 = clamp(regionx2, 0, barw)
			
		// Highlight bar area
		draw_box(barx + x1, bary, x2 - x1, barh, false, c_accent_overlay, a_accent_overlay)
			
		// Darken left
		draw_box(barx, bary, x1, markerh + barh, false, c_black, a_dark_overlay)
			
		// Darken right
		draw_box(barx + x2, bary, (barx + barw) - (barx + x2), markerh + barh, false, c_black, a_dark_overlay)
			
		x1 = regionx1
		x2 = regionx2
			
		// Start/end markers
		if (x1 >= -32 && x1 <= (barw + 32))
		{
			draw_image(spr_marker_region, 0, barx + x1, bary, 1, 1, c_accent, 1)
			draw_box(barx + x1, bary, 1, markerh + barh, false, c_accent, 1)
		}
			
		if (x2 >= -32 && x2 <= (barw + 32))
		{
			draw_image(spr_marker_region, 1, barx + x2 + 10, bary, 1, 1, c_accent, 1)
			draw_box(barx + x2, bary, 1, markerh + barh, false, c_accent, 1)
		}
	}
	
	// Frames
	framestep = 1
	framehighlight = 5
	
	if (timeline_zoom < 5)
	{
		framestep = 5
		framehighlight = 10
	}
	
	if (timeline_zoom < 3)
	{
		framestep = 10
		framehighlight = 50
	}
	
	if (timeline_zoom < 1)
	{
		framestep = 20
		framehighlight = 100
	}
	
	if (timeline_zoom < 0.5)
	{
		framestep = 50
		framehighlight = 200
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
				
				draw_line_ext(linex, tly, linex, tly + (ds_list_size(tree_visible_list) * itemh), linecolor, linealpha)
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
	
	// Keyframes
	dy = tly
	for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
	{
		if (dy > tly + tlh)
			break
		
		dx = tlx
		var tl = tree_visible_list[|t];
		
		// Draw ghosts
		if (window_busy = "timelinemovekeyframes")
		{
			for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
			{
				var kf, sound;
				kf = tl.keyframe_list[|k]
				
				if (!kf.selected)
					continue
				
				sound = kf.value[e_value.SOUND_OBJ]
				
				dx = tlx + floor(kf.move_pos * timeline_zoom - timeline.hor_scroll.value)
				
				if (dx > tlx + (tlw + 32))
					break
				
				if (tl.type = e_tl_type.AUDIO && sound && sound.ready)
				{
					var boxw = tl_keyframe_length(kf) * timeline_zoom;
					if (dx + boxw < tlx)
						continue
					
					draw_box(dx, dy, boxw, itemh, false, c_border, a_border)
				}
				else
				{
					if (dx < (tlx - 32))
						continue
					
					draw_image(spr_icons, icons.KEYFRAME_FILLED_SMALL, dx + 1, dy + itemhalf, 1, 1, c_level_top, 1)
					draw_image(spr_icons, icons.KEYFRAME_FILLED_SMALL, dx + 1, dy + itemhalf, 1, 1, c_text_tertiary, a_text_tertiary)
				}
			}
		}
		
		// Draw keyframes
		var framecolor, framealpha;
		framecolor = c_text_secondary
		framealpha = a_text_secondary
		
		if (tl.color_tag != null)
		{
			framecolor = setting_theme.accent_list[tl.color_tag]
			framealpha = .75	
		}
		
		for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
		{
			var kf, mouse, sound, pitch;
			kf = tl.keyframe_list[|k]
			dx = tlx + floor(kf.position * timeline_zoom - timeline.hor_scroll.value)
			sound = kf.value[e_value.SOUND_OBJ]
			pitch = kf.value[e_value.SOUND_PITCH]
			
			if (tl.type = e_tl_type.AUDIO && sound && sound.ready)
			{
				var soundlen, boxx, boxw, startsample, samplesshow, prec, wavehei, alpha;
				
				if (dx > tlx + tlw)
					break
				
				soundlen = max(0, pitch == 0 ? 0 : ((sound.sound_samples / sample_rate / pitch) - kf.value[e_value.SOUND_START] + kf.value[e_value.SOUND_END]))
				
				boxx = max(tlx, dx)
				boxw = min(tlw, soundlen * project_tempo * timeline_zoom - max(0, tlx - dx))
				
				if (boxw <= 0)
					continue
				
				startsample = floor((max(0, tlstartpos - kf.position) / project_tempo + kf.value[e_value.SOUND_START]) * sample_rate)
				samplesshow = ((boxw / timeline_zoom) / project_tempo) * sample_rate
				
				prec = sample_rate / sample_avg_per_sec
				wavehei = itemhalf * kf.value[e_value.SOUND_VOLUME]
				alpha = draw_get_alpha()
				
				// Audio background
				if (kf.selected)
				{
					draw_box(boxx, dy, boxw, itemh, false, c_level_middle, 1)
					draw_box(boxx, dy, boxw, itemh, false, c_accent_overlay, a_accent_overlay)
				}
				
				// Draw samples
				draw_primitive_begin(pr_linelist)
				for (var xx = 0; xx < boxw; xx++)
				{
					var ind, maxv, minv, miny, maxy;
					ind = (((startsample * pitch) + floor((xx / boxw) * samplesshow) * pitch) mod sound.sound_samples) div prec
					maxv = sound.sound_max_sample[ind]
					minv = sound.sound_min_sample[ind]
					if (xx > 0 && xx mod 500 = 0) // GM bug
					{
						draw_primitive_end()
						draw_primitive_begin(pr_linelist)
					}
					
					miny = clamp(dy + itemhalf - minv * wavehei, dy, dy + itemh) + 1
					maxy = clamp(dy + itemhalf - maxv * wavehei, dy, dy + itemh)
					
					draw_vertex_color(boxx + xx + 1, maxy, kf.selected ? c_accent : framecolor, kf.selected ? 1 : framealpha)
					draw_vertex_color(boxx + xx + 1, miny, kf.selected ? c_accent : framecolor, kf.selected ? 1 : framealpha)
				}
				draw_primitive_end()
				
				mouse = app_mouse_box(boxx - timeline_zoom / 2, dy, boxw + timeline_zoom * 2, itemh)
				
				if (kf.selected && boxw > 20)
				{
					if (app_mouse_box(boxx, dy, 5, itemh) && mouseintl && !tl.lock)
						mousekfstart = kf
					else if (app_mouse_box(boxx + boxw - 5, dy, 5, itemh) && mouseintl && !tl.lock)
						mousekfend = kf
				}
			}
			else
			{
				// Invisible
				if ((!kf.value[e_value.VISIBLE] || !kf.value[e_value.SPAWN]) && !tl.hide && tl.type != e_tl_type.AUDIO)
				{
					var curdx, nextdx;
					curdx = ((k = 0) ? tlx : max(tlx, dx))
					nextdx = tlx + tlw
					if (k < ds_list_size(tl.keyframe_list) - 1)
						nextdx = min(nextdx, tlx + floor(tl.keyframe_list[|k + 1].position * timeline_zoom - timeline.hor_scroll.value))
					
					// Block out area
					if (curdx < nextdx && nextdx >= 0)
						draw_box(curdx, dy, nextdx - curdx, itemh - 1, false, c_black, .25)
				}
				
				if (dx > (tlx + tlw + 32))
					break
				
				if (dx < (tlx - 32))
					continue
				
				mouse = (((mouse_x >= dx - 8 && mouse_x < dx + 8) || timeline_mouse_pos = kf.position) && tl = mousetl)
				
				// Sprite
				var image = ((round(timeline_marker) = kf.position && tl.selected) || kf.selected);
				
				draw_image(spr_icons, image ? icons.KEYFRAME : icons.KEYFRAME_FILLED, dx + 1, dy + itemhalf, 1, 1, c_level_top, 1)
				draw_image(spr_icons, image ? icons.KEYFRAME : icons.KEYFRAME_FILLED, dx + 1, dy + itemhalf, 1, 1, kf.selected ? c_accent : framecolor, kf.selected ? 1 : framealpha)
			}
			
			if (mouse && mouseintl && !tl.lock)
				mousekf = kf
		}
		
		dy += itemh
	}
	
	// Selecting keyframes
	if (window_busy = "timelineselectkeyframes")
	{
		mouse_cursor = cr_handpoint
		
		var x1, y1, x2, y2;
		x1 = clamp(mouse_click_x + (timeline_select_starth - timeline.hor_scroll.value), tlx, tlx + tlw)
		y1 = clamp(mouse_click_y + (timeline_select_startv - timeline.ver_scroll.value), tly, tly + tlh)
		x2 = clamp(mouse_x, tlx, tlx + tlw)
		y2 = clamp(mouse_y, tly, tly + tlh)
		
		if (x2 < x1)
		{
			var swap = x1;
			x1 = x2
			x2 = swap
		}
		x2 -= x1
		
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
				var stl, etl, spos, epos, tmp;
				
				stl = (mouse_click_y - tly + timeline_select_startv) / itemh
				etl = (mouse_y - tly + timeline.ver_scroll.value) / itemh
				spos = (mouse_click_x - tlx + timeline_select_starth) / timeline_zoom
				epos = (mouse_x - tlx + timeline.hor_scroll.value) / timeline_zoom
				
				if (stl > etl)
				{
					tmp = stl
					stl = etl
					etl = tmp
				}
				
				if (spos > epos)
				{
					tmp = spos
					spos = epos
					epos = tmp
				}
				
				if (stl < ds_list_size(tree_visible_list))
				{
					stl = clamp(floor(stl), 0, ds_list_size(tree_visible_list) - 1)
					etl = clamp(floor(etl), 0, ds_list_size(tree_visible_list) - 1)
					spos = max(0, round(spos))
					epos = max(0, round(epos))
					action_tl_keyframes_select_area(stl, etl, spos, epos)
				}
			}
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	// Marker
	markerx = floor(timeline_marker * timeline_zoom - timeline.hor_scroll.value)
	markery = 0
	
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
	
	// Markers
	if (markerbarh != 0)
	{
		var barmouseon, markx, markeditx, marky, markw, markh, marker, color, name, markermouseon, markermouseonx;
		barmouseon = app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh)
		markermouseon = null
		content_mouseon = app_mouse_box(markerbarx, markerbary, markerbarw, markerbarh) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
		
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
			
			if (barmouseon && app_mouse_box(markx, marky, markw, markh))
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
	
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	// Timeline list
	var tl, buttonsize, buttonpad;
	var itemx, itemy, itemw, itemhover, buttonhover, minw, xx, xright;
	buttonsize = 16
	buttonpad = (itemh - buttonsize)/2
	
	draw_box(content_x, bary, listw, content_height - headerh, false, c_level_middle, 1)
	draw_divide_vertical(content_x + listw, tly - barh, content_height - headerh)
	draw_divide(content_x, bary, listw)
	
	// Filter (advanced mode only)
	if (setting_advanced_mode)
	{
		if (draw_button_icon("timelinefilter", listx + 8, bary + 4, 24, 24, setting_timeline_hide_ghosts || !array_equals(timeline_hide_color_tag, array_create(array_length(timeline_hide_color_tag), false)), icons.FILTER, null, false, "tooltiptlfilter"))
		{
			menu_settings_set(listx + 8, bary + 4, "timelinefilter", 24)
			settings_menu_script = tl_filter_draw
			settings_menu_above = true
		}
	
		if (settings_menu_name = "timelinefilter" && settings_menu_ani_type != "hide")
			current_microani.active.value = true
	}
	
	// Draw search bar
	var searchx, searchwid;
	searchx = (setting_advanced_mode ? listx + (24 + 16) : listx + 8) 
	searchwid = (setting_advanced_mode ? listw - (24 + 24) : listw - 16) 
	timeline.tbx_search.text = timeline_search
	draw_textfield("timelinesearch", searchx, bary + 4, searchwid, 24, timeline.tbx_search, action_tl_search, text_get("listsearch"), "none")
	
	// Context menu
	if (mouseinnames)
		context_menu_area(listx, listy, listw, listh, "timelinelist", mousetl, null, null, null)
	
	dy = listy
	
	var itemmaxw;
	tlmaxw = 0
	for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
	{
		if (dy > listy + listh)
			break
		
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
		
		if ((itemhover && mouse_left) || tl.selected)
			draw_box(content_x, itemy, listw, itemh, false, c_accent_overlay, a_accent_overlay)
		else if (tl.selected || itemhover || tl = context_menu_value || (window_busy = "timelineclick" && timeline_select = tl))
			draw_box(content_x, itemy, listw, itemh, false, c_overlay, a_overlay)
		
		xx = itemx + itemw - ((buttonsize + 4) * (itemhover || tl.hide || tl.lock || (!setting_timeline_hide_ghosts && tl.ghost)))
		
		// Hide/mute
		if (itemhover || tl.hide)
		{
			if (tl.type != e_tl_type.AUDIO)
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
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize)
		}
		xx -= (buttonsize + 4) * (itemhover || tl.lock || (!setting_timeline_hide_ghosts && tl.ghost))
		itemmaxw += buttonsize + buttonpad
		
		// Lock
		if (itemhover || tl.lock)
		{
			if (draw_button_icon("timelinelock" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, tl.lock, tl.lock ? icons.LOCK_SMALL : icons.UNLOCK_SMALL, null, false, (tl.lock ? "tooltiptlunlock" : "tooltiptllock")))
				action_tl_lock(tl)
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize)
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
				
				buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize)
			}
		}
		itemmaxw += buttonsize + buttonpad
		
		// Select all keyframes
		xx -= (buttonsize + 4) * itemhover
		
		if (itemhover)
		{
			if (draw_button_icon("timelineselectkeyframes" + string(tl), xx, itemy + buttonpad, buttonsize, buttonsize, false, icons.KEYFRAME_SMALL, null, false, "contextmenutlselectkeyframes"))
				action_tl_select_keyframes(tl)
			
			buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize)
		}
		
		itemmaxw += buttonsize + buttonpad
		
		minw = xx - itemx
		xright = xx
		
		xx = itemx + 4
		minw -= 4
		
		// Hierarchy connections (If hierarchy is possible)
		if (tlhierarchy)
		{
			var connectx = content_x + 4 - timeline.hor_scroll_tl.value;
			var index = null;
			
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
				
				buttonhover = buttonhover || app_mouse_box(xx, itemy + buttonpad, buttonsize, buttonsize)
				
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
			
			if (tl.type != null && (((xx + 24) - xright) < minw))
				draw_image(spr_icons, list[|tl.type], xx + (buttonsize/2), itemy + (itemh/2), 1, 1, iconcolor, iconalpha)
			
			xx += 24
			minw -= 24
			itemmaxw += 24
		}
		xx += 1
		
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
				namecolor = c_text_main
				namealpha = a_text_main
				backalpha = .25
			}
			
			if (dev_mode_debug_saveid)
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
			if (app_mouse_box(xx - 28, itemy, string_width(name) + 28, itemh))
				mousetlname = tl
			
			window_busy = "timelineclick"
		}
		
		// Rename
		if (mouse_left_double_pressed && app_mouse_box(xx, itemy, string_width(name), itemh))
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
			for (var i = 0; i < e_tl_type.amount - 1; i++)
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
	
	// Timeline list scrollbar
	if (timeline.hor_scroll_tl.needed)
		draw_box(listx, listy + listh, listw, 12, false, c_level_middle, 1)
	
	scrollbar_draw(timeline.hor_scroll_tl, e_scroll.HORIZONTAL, listx, listy + listh, listw, tlmaxw)
	
	// Resize list
	if (app_mouse_box(tlx - 5, tly - barh, 5, content_height - headerh))
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
	
	// Context menu
	if (window_busy = "" && mouseintl)
		context_menu_area(content_x, content_y, content_width, content_height, "timeline", null, null, null, null)
	
	// Sound resize
	if (mousekfstart)
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
			action_tl_keyframes_sound_resize_start()
	}
	
	// Set sound end
	if (mousekfend)
	{
		mouse_cursor = cr_size_we
		if (mouse_left_pressed)
		{
			timeline_sound_end_mousex = mouse_x + timeline.hor_scroll.value
			timeline_sound_end_value = mousekfend.value[e_value.SOUND_END]
			window_focus = "timeline"
			window_busy = "timelinesetsoundend"
		}
	}
	
	// Click timeline / Start dragging
	if (window_busy = "" && mouseintl && !mousekfstart && !mousekfend)
	{
		mouse_cursor = cr_handpoint
		if (mouse_left_pressed)
		{
			window_focus = "timeline"
			action_tl_play_break()
			
			if (mousekf)
			{
				if (mousekf.selected)
				{
					if (keyboard_check(vk_shift)) // Deselect
					{
						action_tl_keyframe_deselect(mousekf.timeline, mousekf)
						app_mouse_clear()
					}
					else // Start moving selection
						action_tl_keyframes_move_start(mousekf)
				}
				else if ((tl_keyframe_length(mousekf) != 0 && (timeline_marker >= mousekf.position) && (timeline_marker <= mousekf.position + tl_keyframe_length(mousekf))) || (tl_keyframe_length(mousekf) = 0)) // Select
				{
					if (keyboard_check(vk_shift))
						action_tl_keyframe_select(mousekf.timeline, mousekf)
					else
						action_tl_keyframe_select_single(mousekf.timeline, mousekf)
					
					action_tl_keyframes_move_start(mousekf)
				}
				else
					action_tl_select(mousekf.timeline)
				
				if (mousekf.timeline.type = e_tl_type.AUDIO && mousekf.value[e_value.SOUND_OBJ])
					timeline_marker = timeline_mouse_pos
				else
					timeline_marker = mousekf.position
			}
			else
			{
				window_busy = "timelineclickkeyframes"
				if (mousetl && mousetl.lock)
					timeline_select = null
				else
					timeline_select = mousetl
				timeline_select_starth = timeline.hor_scroll.value
				timeline_select_startv = timeline.ver_scroll.value
			}
		}
		
		if (mouse_middle_pressed)
		{
			window_focus = "timeline"
			window_busy = "timelinedrag"
		}
	}
	
	// Resize sounds
	if (window_busy = "timelineresizesounds")
	{
		mouse_cursor = cr_size_we
		if (!mouse_left)
			action_tl_keyframes_sound_resize_done()
		else
			action_tl_keyframes_sound_resize()
	}
	
	// Set sound end
	if (window_busy = "timelinesetsoundend")
	{
		var newval = timeline_sound_end_value + ((mouse_x + timeline.hor_scroll.value) - timeline_sound_end_mousex) / (timeline_zoom * project_tempo);
		action_tl_frame_sound_end(newval, false)
		mouse_cursor = cr_size_we
		if (!mouse_left)
			window_busy = ""
	}
	
	// Moving keyframes
	if (window_busy = "timelinemovekeyframes")
	{
		mouse_cursor = cr_size_all
		if (!mouse_left)
			action_tl_keyframes_move_done()
		else
			action_tl_keyframes_move()
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
	
	// Select timelines
	if (window_busy = "timelineselect")
	{
		var x1, y1, x2, y2;
		
		mouse_cursor = cr_handpoint
		
		x1 = clamp(mouse_click_x, content_x, tlx)
		y1 = clamp(mouse_click_y + (timeline_select_startv - timeline.ver_scroll.value), listy, listy + tlh)
		x2 = clamp(mouse_x, content_x, tlx)
		y2 = clamp(mouse_y, listy, listy + tlh)
		
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
						app_update_tl_edit()
				}
				else
					action_tl_select(timeline_select)
			}
			else
				action_tl_deselect_all()
			
			window_busy = ""
		}
	}
	
	// Click keyframes
	if (window_busy = "timelineclickkeyframes")
	{
		mouse_cursor = cr_handpoint
		if (mouse_move > 5) // Select
		{
			if (!keyboard_check(vk_shift) && !keyboard_check(vk_control))
				action_tl_deselect_all()
			
			window_busy = "timelineselectkeyframes"
		}
		if (!mouse_left) // Move marker, select
		{
			if (timeline_select)
			{
				if (timeline_select.selected && timeline_marker = timeline_mouse_pos)
					action_tl_keyframe_create(timeline_select, timeline_mouse_pos)
				else
					action_tl_select(timeline_select)
			}
			else
				action_tl_deselect_all()
			
			timeline_marker = timeline_mouse_pos
			action_tl_play_jump()
			window_busy = ""
		}
	}
	
	// Bar
	if (app_mouse_box(barx, bary + 5 * (tab.panel = panel_map[?"bottom"]), barw, barh - 5 * (tab.panel = panel_map[?"bottom"])) && !popup_mouseon && !context_menu_mouseon && !toast_mouseon)
	{
		mouse_cursor = cr_handpoint
		
		// Change region
		if (timeline_region_start != null)
		{
			if (app_mouse_box(barx + regionx1 - 8, bary, 8, barh))
			{
				mouse_cursor = cr_size_we
				if (mouse_left_pressed)
				{
					window_focus = "timeline"
					window_busy = "timelinesetregionstart"
					timeline_region_pos = timeline_region_end
				}
			}
			else if (app_mouse_box(barx + regionx2, bary, 8, barh))
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
		
		// Create tegion
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
	
	// Zoom
	if (window_scroll_focus_prev = "timelinezoom" && window_busy = "" && mouse_wheel <> 0)
	{
		var m = (mouse_wheel = 1 ? .5 : 2);
		timeline_zoom_goal = clamp(timeline_zoom_goal * m, 0.25, 32)
		if (timeline_zoom_goal > 1)
			timeline_zoom_goal = round(timeline_zoom_goal)
		
		// Convert current and new mouse position to frames, then get difference and add it
		timeline.hor_scroll.value_goal = round(
			timeline.hor_scroll.value +
			((mouse_x - barx + timeline.hor_scroll.value) / timeline_zoom - (mouse_x - barx + timeline.hor_scroll.value) / timeline_zoom_goal) * timeline_zoom_goal
		) 
	}
	
	// Move view
	if (window_busy = "timelinedrag")
	{
		mouse_cursor = cr_size_all
		timeline.hor_scroll.value = max(0, timeline.hor_scroll.value - mouse_dx)
		timeline.ver_scroll.value = max(0, timeline.ver_scroll.value - mouse_dy)
		
		if (!mouse_middle)
		{
			timeline.hor_scroll.value = snap(timeline.hor_scroll.value, timeline.hor_scroll.snap_value)
			timeline.ver_scroll.value = snap(timeline.ver_scroll.value, timeline.ver_scroll.snap_value)
			window_busy = ""
		}
		
		timeline.ver_scroll.value_goal = timeline.ver_scroll.value
		timeline.hor_scroll.value_goal = timeline.hor_scroll.value
	}
	
	// Move view when selecting
	if (window_busy = "timelinemove" || window_busy = "timelineselect")
	{
		if (mouse_y < tly)
			timeline.ver_scroll.value -= 8
		
		if (mouse_y > tly + tlh)
			timeline.ver_scroll.value += 8
		
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
		window_busy = "timelinemovemarker")
	{
		if (mouse_x < tlx)
			timeline.hor_scroll.value -= 15
		
		if (mouse_x > tlx + tlw)
			timeline.hor_scroll.value += 15
		
		if (window_busy != "timelinemovemarker")
		{
			if (mouse_y < tly)
				timeline.ver_scroll.value -= 8
			
			if (mouse_y > tly + tlh)
				timeline.ver_scroll.value += 8
		}
		
		timeline.ver_scroll.value = max(0, timeline.ver_scroll.value)
		timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
		
		timeline.ver_scroll.value_goal = timeline.ver_scroll.value
		timeline.hor_scroll.value_goal = timeline.hor_scroll.value
	}
	
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height) && !popup_mouseon && !toast_mouseon && !context_menu_mouseon
	
	// Vertical scrollbar
	if (tlw > 16)
	{
		if (timeline.ver_scroll.needed)
			draw_box(content_x + content_width - 12, tly, 12, tlh, false, c_level_middle, 1)
		
		timeline.ver_scroll.snap_value = itemh
		scrollbar_draw(timeline.ver_scroll, e_scroll.VERTICAL, content_x + content_width - 12, tly, tlh, (ds_list_size(tree_visible_list) + 1) * itemh)
	}
	
	// Horizontal scrollbar
	if (content_height > (barh + headerh + 12) && (!timeline_playing || !setting_timeline_autoscroll))
	{
		if (timeline.hor_scroll.needed)
			draw_box(tlx, content_y + content_height - 12, content_width - listw, 12, false, c_level_middle, 1)
		
		scrollbar_draw(timeline.hor_scroll, e_scroll.HORIZONTAL, tlx, content_y + content_height - 12, tlw, floor(max(timeline_length, timeline_marker, timeline_marker_length) * timeline_zoom + tlw))
	}
	
	if (content_mouseon)
	{
		shortcut_bar_state = "timeline"
		
		if (mouseintl)
			shortcut_bar_state = "timelinekeyframes"
		
		if (mouseinnames)
			shortcut_bar_state = "timelinenames"
		
		if (mouseinbar)
			shortcut_bar_state = "timelinebar"
		
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
