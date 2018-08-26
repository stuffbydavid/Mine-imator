/// tab_timeline()

var itemh, itemhalf, indent;
var tlx, tly, tlw, tlh, tlstartpos;
var listx, listy, listw, listh;
var mouseintl, mouseinnames, mousetl, mousetlname, mousekf, mousekfstart, mousekfend;
var mousemovetl, mousemoveindex, movehltl, movehlpos;
var barx, bary, barw, barh;
var framestep, framehighlight, f;
var markerx, markery;
var regionx1, regionx2;

content_mouseon = true

// Background
draw_box(content_x, content_y, content_width, content_height, false, setting_color_background, 1)

// Init
itemh = test(setting_timeline_compact, 18, 24)
itemhalf = itemh / 2
indent = 16

// List
listx = content_x
listw = min(timeline.list_width, content_width)
listy = content_y
listh = floor((content_height - 30) / itemh) * itemh

// Timeline
tlx = content_x + listw
tly = content_y
tlw = content_width - 30 * timeline.ver_scroll.needed - listw
tlh = listh

// Adjust by panel location
if (tab.panel = panel_map[?"left_top"] || tab.panel = panel_map[?"left_bottom"])
	tlw -= 5
else if (tab.panel = panel_map[?"right_top"] || tab.panel = panel_map[?"right_bottom"])
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
	
// Bar
barw = content_width - tab.list_width
barh = 28
barx = tlx
bary = tly - barh

// Mouse
mouseintl = (app_mouse_box(tlx, tly, tlw, tlh) && !popup_mouseon)
mouseinnames = (app_mouse_box(listx, listy, listw - 5, listh) && !popup_mouseon)
mousetl = floor((mouse_y - content_y + timeline.ver_scroll.value) / itemh)
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

// Empty
if (project_file != "" && !instance_exists(obj_timeline) && tlw > 500 && content_height > 100)
	draw_label(text_get("timelineempty"), tlx + floor(tlw / 2), tly + floor(content_height / 2), fa_center, fa_middle, null, 0.3, setting_font_big)

// Keyframe backgrounds
dy = tly
for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
{
	if (dy + itemh > tly + tlh)
		break
		
	dx = tlx
	var tl = tree_visible_list[|t];
	
	draw_box(dx, dy, tlw, itemh - 1, false, setting_color_interface, 1)
	
	// Select highlight
	if (tl.selected)
		draw_box(dx, dy, tlw, itemh - 1, false, setting_color_timeline_select, 1)
	else
		draw_box(dx, dy, tlw, itemh - 1, false, c_black, 0.025 + 0.04 * (t mod 2))
	
	// Hidden
	if (tl.hide)
		draw_box(dx, dy, tlw, itemh - 1, false, c_black, 0.25)
	
	dy += itemh
}

// Timeline bar
draw_box(barx, bary, barw, barh - 1, false, setting_color_timeline, 1)

// Timeline region
if (timeline_region_start != null)
{
	regionx1 = floor(timeline_region_start * timeline_zoom - timeline.hor_scroll.value)
	regionx2 = floor(timeline_region_end * timeline_zoom - timeline.hor_scroll.value)
	
	var x1, x2;
	x1 = regionx1
	x2 = regionx2
	if (x1 < barw && x2 > 0)
	{
		x1 = clamp(x1, 0, barw)
		x2 = clamp(x2, 0, barw)
		
		draw_box(barx + x1, bary, x2 - x1, barh - 1, false, setting_color_highlight, 1)
		
		if (x1 >= 0)
			draw_image(spr_marker, 1, barx + x1, bary, 1, content_height + barh, setting_color_highlight, 1)
			
		if (x2 < barw)
			draw_image(spr_marker, 1, barx + x2, bary, 1, content_height + barh, setting_color_highlight, 1)
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

for (dx = 1 - (timeline.hor_scroll.value mod (timeline_zoom * framestep)); dx < barw; dx += timeline_zoom * framestep)
{
	var highlight, linex, color, linecolor, alpha, fullsec, halfsec, inregion;
	highlight = ((f mod framehighlight) = 0)
	linex = floor(barx + dx)
	alpha = 1
	fullsec = false
	halfsec = false
	inregion = false
	
	if (timeline_region_start != null && f >= timeline_region_start && f <= timeline_region_end)
	{
		inregion = true
		color = setting_color_highlight_text
	}
	else
		color = setting_color_timeline_text
	
	linecolor = color
	
	if (project_file != "" && instance_exists(obj_timeline) && timeline_show_seconds)
	{
		if (f mod (project_tempo/2) = 0 && f > 0)
		{
			fullsec = false
			halfsec = true
			alpha = 0.35
			linecolor = setting_color_timeline_marks
		}
	
		if (f mod project_tempo = 0 && f > 0)
		{
			fullsec = true
			halfsec = false
			alpha = .8
			linecolor = setting_color_timeline_marks
		}
		
		if (fullsec || halfsec)
			color = setting_color_timeline_marks
	}
	
	// Horizontal line at base of notches of timeline bar
	if ((fullsec || halfsec) && !inregion)
		draw_line_ext(linex - 2, bary + barh - 1, linex + 1, bary + barh - 1, color, 1)
	
	// Line through timeline
	if (fullsec || halfsec)
		draw_line_ext(linex, bary + barh - 1, linex, content_y + content_height, linecolor, alpha)
	
	if (inregion)
		linecolor = setting_color_highlight_text
	
	// Vertical notch in timeline bar
	draw_line_ext(linex, (bary + barh - 3 - 2 * highlight) - 2 * (fullsec || halfsec), linex, bary + barh - 1, linecolor, 1)
	
	if (highlight)
	{
		var oldcol = draw_get_color();
		draw_set_color(color)
		draw_set_halign(test((f = 0), fa_left, fa_center))
		draw_text(linex, bary + 5, string(f))
		draw_set_halign(fa_left)
		draw_set_color(oldcol)
	}
		
	f += framestep
}

// Keyframes
dy = tly
for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
{
	if (dy + itemh > tly + tlh)
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
			
			if (dx > tlx + tlw)
				break
			
			if (tl.type = e_tl_type.AUDIO && sound && sound.ready)
			{
				var boxw = tl_keyframe_length(kf) * timeline_zoom;
				if (dx + boxw < tlx)
					continue
				draw_box(dx, dy, boxw, itemh, false, c_black, 0.1)
			}
			else
			{
				if (dx < tlx)
					continue
				draw_image(spr_keyframe, 1, dx + 1, dy + itemhalf, 1, 1, tl.color, 0.1)
			}
		}
	}
	
	// Draw keyframes
	for (var k = 0; k < ds_list_size(tl.keyframe_list); k++)
	{
		var kf, mouse, sound;
		kf = tl.keyframe_list[|k]
		dx = tlx + floor(kf.position * timeline_zoom - timeline.hor_scroll.value)
		sound = kf.value[e_value.SOUND_OBJ]
		
		if (tl.type = e_tl_type.AUDIO && sound && sound.ready)
		{
			var soundlen, boxx, boxw, startsample, samplesshow, prec, wavehei, alpha;
			
			if (dx > tlx + tlw)
				break
				
			soundlen = max(0, sound.sound_samples / sample_rate - kf.value[e_value.SOUND_START] + kf.value[e_value.SOUND_END])
			
			boxx = max(tlx, dx)
			boxw = min(tlw, soundlen * project_tempo * timeline_zoom - max(0, tlx - dx))
			
			if (boxw <= 0)
				continue
			
			startsample = floor((max(0, tlstartpos - kf.position) / project_tempo + kf.value[e_value.SOUND_START]) * sample_rate)
			samplesshow = ((boxw / timeline_zoom) / project_tempo) * sample_rate
			
			prec = sample_rate / sample_avg_per_sec
			wavehei = itemhalf * kf.value[e_value.SOUND_VOLUME]
			alpha = draw_get_alpha()
			
			// Background
			if (kf.selected)
				draw_box(boxx, dy, boxw, itemh, false, setting_color_buttons_pressed, 1)
				
			// Draw samples
			draw_primitive_begin(pr_linelist)
			for (var xx = 0; xx < boxw; xx++)
			{
				var ind, maxv, minv;
				ind = ((startsample + floor((xx / boxw) * samplesshow)) mod sound.sound_samples) div prec
				maxv = sound.sound_max_sample[ind]
				minv = sound.sound_min_sample[ind]
				if (xx > 0 && xx mod 500 = 0) // GM bug
				{
					draw_primitive_end()
					draw_primitive_begin(pr_linelist)
				}
				draw_vertex_color(boxx + xx + 1, dy + itemhalf - maxv * wavehei, test(kf.selected, c_white, tl.color), alpha)
				draw_vertex_color(boxx + xx + 1, dy + itemhalf - minv * wavehei + 1, test(kf.selected, c_white, tl.color), alpha)
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
				curdx = test((k = 0), tlx, max(tlx, dx))
				nextdx = tlx + tlw
				if (k < ds_list_size(tl.keyframe_list) - 1)
					nextdx = min(nextdx, tlx + floor(tl.keyframe_list[|k + 1].position * timeline_zoom - timeline.hor_scroll.value))
				if (curdx < nextdx && nextdx >= 0)
					draw_box(curdx, dy, nextdx - curdx, itemh - 1, false, c_black, 0.25)
			}
			
			if (dx > tlx + tlw)
				break
				
			if (dx < tlx)
				continue
			
			mouse = (((mouse_x >= dx - 8 && mouse_x < dx + 8) || timeline_mouse_pos = kf.position) && tl = mousetl)
			
			// Sprite
			var image = ((round(timeline_marker) = kf.position && tl.selected) || kf.selected);
			
			if (kf.selected)
				image = 2
				
			draw_image(spr_keyframe, image, dx + 1, dy + itemhalf, 1, 1, test(kf.selected, c_white, tl.color), 1)
			
			if (kf.selected)
				draw_image(spr_keyframe, 3, dx + 1, dy + itemhalf, 1, 1, setting_color_highlight, 1)
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
	render_set_culling(false)
	draw_box(x1, y1, x2 - x1, y2 - y1, false, setting_color_timeline_select_box, 0.25)
	draw_box(x1, y1, x2 - x1, y2 - y1, true, setting_color_timeline_select_box, 1)
	render_set_culling(true)
	
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
	
	while (markerx > barw)
	{
		timeline.hor_scroll.value += barw
		markerx = floor(timeline_marker * timeline_zoom - timeline.hor_scroll.value)
	}
	
	timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
}

if (markerx >= 0 && markerx < tlw)
{
	draw_image(spr_marker, 0, tlx + 1 + markerx, content_y - barh + markery, 1, 1, setting_color_timeline_text, 1)
	draw_image(spr_marker, 1, tlx + 1 + markerx, content_y - barh + markery + 8, 1, content_height + barh - 8-markery, setting_color_timeline_text, 1)
}

// Timeline list
draw_box(content_x, tly, listw, content_height, false, setting_color_interface, 1)
dy = listy
for (var t = timeline_list_first; t < ds_list_size(tree_visible_list); t++)
{
	var tl, level, mouse, w, textcol, name;
	var showkeyframes, showlock, showhide;
	
	if (dy + itemh > listy + listh)
		break
	
	tl = tree_visible_list[|t]
	level = tl.level
	dx = listx + 5 + level * indent
	w = listw - 5
	textcol = setting_color_text
	
	// Select highlight
	if (tl.selected)
	{
		draw_box(content_x, dy, listw, itemh - 1, false, setting_color_timeline_select, 1)
		draw_set_font(setting_font_bold)
	}
	else if (window_busy = "timelinemove")
	{
		// Move highlight
		if (timeline_move_highlight_tl = tl)
		{
			draw_box(content_x, dy, listw, itemh - 1, false, setting_color_highlight, 1)
			textcol = setting_color_highlight_text
		}
		else if (timeline_move_highlight_tl = null)
		{
			if (timeline_move_highlight_pos = t)
				draw_box(content_x, max(tly, dy - 2), listw, 4, false, setting_color_highlight, 1)
			else if (timeline_move_highlight_pos = t + 1)
				draw_box(content_x, dy + itemh - 2, listw, 4, false, setting_color_highlight, 1)
		}
	
		// Set move target
		var index = ds_list_find_index(tl.parent.tree_list, tl);
		if ((mouse_y >= dy || t = timeline_list_first) && mouse_y < dy + 8)
		{
			mousemovetl = tl.parent
			mousemoveindex = index
			movehlpos = t
		}
		else if (mouse_y > dy + itemh - 8)
		{
			if (tl.tree_extend && ds_list_size(tl.tree_list) > 0)
			{
				mousemovetl = tl
				mousemoveindex = 0
			}
			else if (tl.parent != app && index = ds_list_size(tl.parent.tree_list) - 1)
			{
				mousemovetl = tl.parent.parent
				mousemoveindex = ds_list_find_index(tl.parent.parent.tree_list, tl.parent) + 1
			}
			else
			{
				mousemovetl = tl.parent
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
	
	// Hide
	if ((mouseinnames && tl = mousetl) || (window_busy = "timelineclick" && timeline_select = tl))
	{
		showkeyframes = true
		showlock = true
		showhide = true
		
		if (app_mouse_box(content_x + w - 16 * 3, dy, 16 * 3, itemh) && mouse_left_pressed)
		{
			window_focus = string(timeline.ver_scroll)
			
			if (app_mouse_box(content_x + w - 16 * 1, dy, 16, itemh))
				action_tl_hide(tl)
				
			if (app_mouse_box(content_x + w - 16 * 2, dy, 16, itemh))
				action_tl_lock(tl)
				
			if (app_mouse_box(content_x + w - 16 * 3, dy, 16, itemh))
				action_tl_select_keyframes(tl)
				
			app_mouse_clear()
		}
		timeline_move_off_x = dx - mouse_x
		timeline_move_off_y = dy - mouse_y
	}
	else
	{
		showkeyframes = false
		showlock = tl.lock
		showhide = tl.hide
	}
	
	if (showkeyframes)
	{
		tip_set(text_get("timelinekeyframestip"), content_x + w - 16 * 3, dy, 16, itemh)
		draw_image(spr_icons, icons.KEYFRAME, content_x + w - 16 * 3 + 8, dy + itemh / 2, 1, 1, setting_color_text, 1)
	}
	
	if (showlock)
	{
		tip_set(text_get("timelinelocktip"), content_x + w - 16 * 2, dy, 16, itemh)
		draw_image(spr_icons, test(tl.lock, icons.LOCK, icons.UNLOCK), content_x + w - 8 - 16 * 1, dy + itemh / 2, 1, 1, setting_color_text, 1)
	}
	
	if (showhide)
	{
		tip_set(text_get(test((tl.type = e_tl_type.AUDIO), "timelinemutetip", "timelinehidetip")), content_x + w - 16 * 1, dy, 16, itemh)
		draw_image(spr_icons, test((tl.type = e_tl_type.AUDIO), test(tl.hide, icons.MUTE, icons.SOUND), test(tl.hide, icons.HIDE, icons.SHOW)), content_x + w - 8 - 16 * 0, dy + itemh / 2, 1, 1, setting_color_text, 1)
	}
	
	if (showkeyframes)
		w -= 16 * 3
	else if (showlock)
		w -= 16 * 2
	else if (showhide)
		w -= 16 * 1
	
	// Expander / Collapser
	if (ds_list_size(tl.tree_list) > 0 && dx - listx + 10 < w)
	{
		if (app_mouse_box(listx, dy, dx - listx + 10, itemh) && mouse_left_pressed)
		{
			window_focus = string(timeline.ver_scroll)
			action_tl_extend(tl)
			app_mouse_clear()
		}
		draw_image(spr_icons, test(tl.tree_extend, icons.ARROW_DOWN_TINY, icons.ARROW_RIGHT_TINY), dx + 2, dy + itemh / 2, 1, 1, textcol, 1)
		dx += 10
	}
	
	// Name
	name = string_limit(string_remove_newline(tl.display_name), w - (dx - listx))
	if (dev_mode)
		name += " [" + string(tl.save_id) + "]"
		
	if (window_busy = "timelineclick")
	{
		window_busy = ""
		if (app_mouse_box(dx, dy, string_width(name), itemh))
			mousetlname = tl
		window_busy = "timelineclick"
	}
	draw_label(name, dx, dy + itemh / 2, fa_left, fa_middle, textcol, 1)
	
	draw_set_font(setting_font)
	dy += itemh
}

// Tools
dx = listx + 5
dy = listy + content_height - 28

while (true)
{
	// Right
	tip_set_shortcut(setting_key_folder, setting_key_folder_control)
	if (draw_button_normal("timelinefolder", dx, dy, 24, 24, e_button.NO_TEXT, false, false, true, icons.FOLDER))
		action_tl_folder()

	dx += 25
	if (dx + 25 > listx + listw - 5)
		break
		
	tip_set_shortcut(setting_key_duplicate_timelines, setting_key_duplicate_timelines_control)
	if (draw_button_normal("timelineduplicate", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings, icons.DUPLICATE))
		action_tl_duplicate()
		
	dx += 25
	if (dx + 25 > listx + listw - 5)
		break
	
	tip_set_shortcut(setting_key_remove_timelines, setting_key_remove_timelines_control)
	if (draw_button_normal("timelineremove", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings, icons.REMOVE))
		action_tl_remove()
	
	dx += 25
	if (dx + 25 > listx + listw - 5)
		break
		
	if (draw_button_normal("timelinesave", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings, icons.EXPORT))
		object_save()
		
	// Left
	dx = listx + listw - 5-25
	if (dx < 10 + 25 * 4)
		break
		
	if (draw_button_normal("timelineexportkeyframes", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings_keyframes_export, icons.EXPORT_KEYFRAMES))
		keyframes_save()
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	tip_set_shortcut(setting_key_remove_keyframes, setting_key_remove_keyframes_control)
	if (draw_button_normal("timelineremovekeyframes", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings_keyframes, icons.REMOVE_KEYFRAMES))
		action_tl_keyframes_remove()
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	tip_set_shortcut(setting_key_paste_keyframes, setting_key_paste_keyframes_control)
	if (draw_button_normal("timelinepastekeyframes", dx, dy, 24, 24, e_button.NO_TEXT, false, false, (copy_kf_amount > 0), icons.PASTE_KEYFRAMES))
		action_tl_keyframes_paste(timeline_insert_pos)
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	tip_set_shortcut(setting_key_cut_keyframes, setting_key_cut_keyframes_control)
	if (draw_button_normal("timelinecutkeyframes", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings_keyframes, icons.CUT_KEYFRAMES))
		action_tl_keyframes_cut()
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	tip_set_shortcut(setting_key_copy_keyframes, setting_key_copy_keyframes_control)
	if (draw_button_normal("timelinecopykeyframes", dx, dy, 24, 24, e_button.NO_TEXT, false, false, timeline_settings_keyframes, icons.COPY_KEYFRAMES))
		tl_keyframes_copy()
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	if (draw_button_normal("timelinerun", dx, dy, 24, 24, e_button.NO_TEXT, false, false, file_exists_lib(timeline_settings_run_fn), icons.RUN))
		action_tl_load_loop(timeline_settings_run_fn)
	dx -= 25
	if (dx < 10 + 25 * 4)
		break
		
	if (draw_button_normal("timelinewalk", dx, dy, 24, 24, e_button.NO_TEXT, false, false, file_exists_lib(timeline_settings_walk_fn), icons.WALK))
		action_tl_load_loop(timeline_settings_walk_fn)
	
	break
}

// Resize list
if (app_mouse_box(tlx - 5, content_y - 20, 5, content_height + 20))
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
	tab.list_width = clamp(timeline_list_resize_start + (mouse_x - mouse_click_x), 100, content_width)
	if (!mouse_left)
		window_busy = ""
}

// Click timeline list
if (window_busy = "" && mouseinnames)
{
	mouse_cursor = cr_handpoint
	if (mouse_left_pressed)
	{
		window_busy = "timelineclick"
		timeline_select = mousetl
		timeline_select_startv = timeline.ver_scroll.value
		window_focus = string(timeline.ver_scroll)
	}
}

// Transition menu
if (window_busy = "" && mouseintl && mouse_right_pressed && tl_edit)
	action_tl_transition_menu(tl_edit.value[e_value.TRANSITION])

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
		action_toolbar_play_break()
		
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
			else if ((timeline_marker >= mousekf.position && timeline_marker <= mousekf.position + tl_keyframe_length(mousekf) && mousekf.timeline.selected) || keyboard_check(vk_shift)) // Select
			{
				action_tl_keyframe_select(mousekf.timeline, mousekf)
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
	y1 = clamp(mouse_click_y + (timeline_select_startv - timeline.ver_scroll.value), content_y, content_y + tlh)
	x2 = clamp(mouse_x, content_x, tlx)
	y2 = clamp(mouse_y, content_y, content_y + tlh)
	render_set_culling(false)
	draw_box(x1, y1, x2 - x1, y2 - y1, false, c_blue, 0.25)
	draw_box(x1, y1, x2 - x1, y2 - y1, true, c_blue, 1)
	render_set_culling(true)
	
	if (!mouse_left)
	{
		if (ds_list_size(tree_visible_list) > 0)
		{
			var stl, etl, tmp;
			
			stl = (mouse_click_y - content_y + timeline_select_startv) / itemh
			etl = (mouse_y - content_y + timeline.ver_scroll.value) / itemh
			
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
		if (mousetlname && mousetlname.selected && mousetlname.part_of = null && !keyboard_check(vk_shift))
			action_tl_move_start()
		else
		{
			if (!keyboard_check(vk_shift))
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
				if (keyboard_check(vk_shift))
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
		if (!keyboard_check(vk_shift))
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
		action_toolbar_play_jump()
		window_busy = ""
	}
}

// Bar
if (app_mouse_box(barx, bary + 5 * (tab.panel = panel_map[?"bottom"]), barw, barh - 5 * (tab.panel = panel_map[?"bottom"])) && !popup_mouseon)
{
	mouse_cursor = cr_handpoint
	
	// Change region
	if (timeline_region_start != null)
	{
		if (app_mouse_box(barx + regionx1, bary, 8, barh))
		{
			mouse_cursor = cr_size_we
			if (mouse_left_pressed)
			{
				window_focus = "timeline"
				window_busy = "timelinesetregionstart"
				timeline_region_pos = timeline_region_end
			}
		}
		else if (app_mouse_box(barx + regionx2 - 8, bary, 8, barh))
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
		action_toolbar_play_break()
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
	if (!mouse_left)
	{
		window_busy = ""
		timeline_marker = round(timeline_marker)
		action_toolbar_play_jump()
		app_mouse_clear()
	}
}

// Zoom
if (window_focus = "timeline" && window_busy = "" && mouse_wheel <> 0)
{
	var m = (1 - 0.5 * mouse_wheel);
	timeline_zoom_goal = clamp(timeline_zoom_goal * m, 0.25, 32)
	if (timeline_zoom_goal > 1)
		timeline_zoom_goal = round(timeline_zoom_goal)
		
	// Convert current and new mouse position to frames, then get difference and add it
	timeline_hscroll_goalvalue = round(
		timeline.hor_scroll.value +
		((mouse_x - barx + timeline.hor_scroll.value) / timeline_zoom - (mouse_x - barx + timeline.hor_scroll.value) / timeline_zoom_goal) * timeline_zoom_goal
	) 
}

if (timeline_zoom != timeline_zoom_goal)
{
	timeline_zoom += (timeline_zoom_goal - timeline_zoom) / max(1, 2 / delta)
	timeline.hor_scroll.value += (timeline_hscroll_goalvalue - timeline.hor_scroll.value) / max(1, 2 / delta)
	timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
}
else
	timeline_hscroll_goalvalue = timeline.hor_scroll.value

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
}

// Move view when selecting
if (window_busy = "timelinemove" || window_busy = "timelineselect")
{
	if (mouse_y < tly)
		timeline.ver_scroll.value -= 8
		
	if (mouse_y > tly + tlh)
		timeline.ver_scroll.value += 8
		
	timeline.ver_scroll.value = max(0, timeline.ver_scroll.value)
}

// Move view when selecting/moving keyframes
if (window_busy = "timelineselectkeyframes" || 
	window_busy = "timelinemovekeyframes" || 
	window_busy = "timelinecreateregion" || 
	window_busy = "timelinesetregionstart" || 
	window_busy = "timelinesetregionend" || 
	window_busy = "timelineresizesounds" || 
	window_busy = "timelinesetsoundend")
{
	if (mouse_x < tlx)
		timeline.hor_scroll.value -= 15
		
	if (mouse_x > tlx + tlw)
		timeline.hor_scroll.value += 15
		
	if (mouse_y < tly)
		timeline.ver_scroll.value -= 8
		
	if (mouse_y > tly + tlh)
		timeline.ver_scroll.value += 8
		
	timeline.ver_scroll.value = max(0, timeline.ver_scroll.value)
	timeline.hor_scroll.value = max(0, timeline.hor_scroll.value)
}

content_mouseon = (app_mouse_box(content_x, content_y, content_width - 5 * (tab.panel = panel_map[?"left_top"] || tab.panel = panel_map[?"left_bottom"]), content_height - 5 * (tab.panel = panel_map[?"top"])) && !popup_mouseon)

// Vertical scrollbar
if (tlw > 16)
{
	timeline.ver_scroll.snap_value = itemh
	scrollbar_draw(timeline.ver_scroll, e_scroll.VERTICAL, content_x + content_width - 30, tly, tlh, ds_list_size(tree_visible_list) * itemh)
}

// Horizontal scrollbar
if (content_height > 0 && (!timeline_playing || !setting_timeline_autoscroll))
	scrollbar_draw(timeline.hor_scroll, e_scroll.HORIZONTAL, tlx, content_y + content_height - 30, tlw, floor(max(timeline_length, timeline_marker) * timeline_zoom + tlw))
