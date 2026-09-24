/// tab_timeline_keyframes(tlx, tly, tlw, tlh, itemh, tlstartpos, mouseintl, mousetl)

function tab_timeline_keyframes(tlx, tly, tlw, tlh, itemh, tlstartpos, mouseintl, mousetl)
{
	var itemhalf = itemh / 2;
	var mousekf = null;
	var mousekfstart = null;
	var mousekfend = null;

	// Process moving keyframes to prevent marker lag
	if (window_busy = "timelinemovekeyframes" && mouse_left)
		action_tl_keyframes_move()

	// Keyframes
	if (tlw > 0 && tlh > 0)
		clip_begin(tlx, tly, tlw, tlh)

	dy = tly - (floor(timeline.ver_scroll.value) - timeline_list_first * itemh)
	for (var t = timeline_list_first; tlw > 0 && tlh > 0 && t < ds_list_size(tree_visible_list); t++)
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
				
				if (tl.type = e_tl_type.AUDIO_TRACK && sound && sound.ready)
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
					
					var kfspr;
					switch (kf.value[e_value.TRANSITION])
					{
						case "instant":
							kfspr = icons.KEYFRAME_INSTANT_FILLED_SMALL
							break
						default:
							kfspr = icons.KEYFRAME_FILLED_SMALL
							break
					}
					
					draw_image(spr_icons, kfspr, dx + 1, dy + itemhalf, 1, 1, c_level_top, 1)
					draw_image(spr_icons, kfspr, dx + 1, dy + itemhalf, 1, 1, c_text_tertiary, a_text_tertiary)
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
			
			if (tl.type = e_tl_type.AUDIO_TRACK && sound && sound.ready && audio_is_ready(sound.sound_index))
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
				
				mouse = app_mouse_box(boxx - timeline_zoom / 2, dy, boxw + timeline_zoom * 2, itemh, "place")
				
				if (kf.selected && boxw > 20)
				{
					if (app_mouse_box(boxx, dy, 5, itemh, "place") && mouseintl && !tl.lock)
						mousekfstart = kf
					else if (app_mouse_box(boxx + boxw - 5, dy, 5, itemh, "place") && mouseintl && !tl.lock)
						mousekfend = kf
				}
			}
			else
			{
				// Invisible
				if ((!kf.value[e_value.VISIBLE] || !kf.value[e_value.SPAWN]) && !tl.hide && tl.type != e_tl_type.AUDIO_TRACK)
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
				var kfspr, image;
				image = ((round(timeline_marker) = kf.position && tl.selected) || kf.selected)
				switch (kf.value[e_value.TRANSITION])
				{
					case "instant":
						kfspr = image ? icons.KEYFRAME_INSTANT : icons.KEYFRAME_INSTANT_FILLED
						break
					default:
						kfspr = image ? icons.KEYFRAME : icons.KEYFRAME_FILLED
						break
				}
				
				draw_image(spr_icons, kfspr, dx + 1, dy + itemhalf, 1, 1, c_level_top, 1)
				draw_image(spr_icons, kfspr, dx + 1, dy + itemhalf, 1, 1, kf.selected ? c_accent : framecolor, kf.selected ? 1 : framealpha)
			}
			
			if (mouse && mouseintl && !tl.lock)
				mousekf = kf
		}
		
		dy += itemh
	}

	if (tlw > 0 && tlh > 0)
		clip_end()

	// Drag select keyframes
	if (window_busy != "timelineclickkeyframes" && window_busy != "timelineselectkeyframes")
		timeline_zoom_current = timeline_zoom
	if (window_busy = "timelineselectkeyframes")
	{
		mouse_cursor = cr_handpoint
		
		var x1, y1, x2, y2;
		x1 = clamp(((((((mouse_click_x - tlx) + timeline_select_starth) / timeline_zoom_current) - (timeline.hor_scroll.value / timeline_zoom)) * timeline_zoom) + tlx), tlx, tlx + tlw) // makes selection box not go wonky during zooming animation
		y1 = clamp(mouse_click_y - (timeline.ver_scroll.value - timeline_select_startv), tly, tly + tlh)
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
				spos = ((mouse_click_x - tlx) + timeline_select_starth) / timeline_zoom_current
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
	
	// Context menu
	if (window_busy = "" && mouseintl)
	{
		if (keyboard_check(vk_shift) && timeline_settings_keyframes)
		{
			if (app_mouse_box(content_x, content_y, content_width, content_height) && mouse_right_released)
			{
				menu_settings_set(mouse_x, mouse_y, "timelinelkeyframetransitions", 0)
				settings_menu_menu = "all"
				settings_menu_script = menu_settings_transitions
				settings_menu_w = 244
				settings_menu_h = 438
				settings_menu_quick = true
				
				if (settings_menu_y + settings_menu_h + 32 > window_height)
					settings_menu_y = (window_height - (settings_menu_h + 32))
			}
		}
		else
			context_menu_area(content_x, content_y, content_width, content_height, "timeline", null, null, null, null)
	}
	
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
					if (keyboard_check(vk_control)) // Deselect
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
				
				if (mousekf.timeline.type = e_tl_type.AUDIO_TRACK && mousekf.value[e_value.SOUND_OBJ])
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
		if (timeline_move_kf_stretch)
			mouse_cursor = cr_size_we
		else
			mouse_cursor = cr_size_all
		
		if (!mouse_left)
			action_tl_keyframes_move_done()
	}
	
	// Scaling keyframes
	if (window_busy = "timelinescalekeyframes")
	{
		mouse_cursor = cr_size_we
		shortcut_bar_state = "timelinescale"
		
		if (keyboard_check_pressed(vk_escape) || mouse_right_pressed)
			action_tl_keyframes_scale_cancel()
		else if (keyboard_check_pressed(vk_enter) || mouse_left_pressed)
			action_tl_keyframes_move_done()
		else
			action_tl_keyframes_scale()
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
}
