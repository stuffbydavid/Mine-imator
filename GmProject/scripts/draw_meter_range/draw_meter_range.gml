/// draw_meter_range(name, x, y, width, min, max, snap, valuemin, valuemax, defaultmin, defaultmax, textboxmin, textboxmax, scriptmin, scriptmax)
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg min
/// @arg max
/// @arg snap
/// @arg valuemin
/// @arg valuemax
/// @arg defaultmin
/// @arg defaultmax
/// @arg textboxmin
/// @arg textboxmax
/// @arg scriptmin
/// @arg scriptmax

function draw_meter_range(name, xx, yy, wid, minrange, maxrange, snapval, minval, maxval, mindef, maxdef, mintbx, maxtbx, minscript, maxscript)
{
	var thumbhei, hei, mouseon, slidermouseon, textfocus, linex, linewid, trackx, trackwid, thumby, minthumbpos, maxthumbpos, minmouseon, maxmouseon;
	
	thumbhei = 20
	hei = (thumbhei + 24)
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
		return 0
	
	mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	slidermouseon = app_mouse_box(xx, yy + 24, wid, thumbhei) && content_mouseon
	
	// Combo textfield, border visibility depends on mouse position
	microani_set(name, null, false, false, false)
	
	textfield_group_add(name + "mininput", minval, mindef, minscript, X, mintbx, null, 0.1, minrange, min(maxval, maxrange))
	textfield_group_add(name + "maxinput", maxval, maxdef, maxscript, X, maxtbx, null, 0.1, max(minval, minrange), maxrange)
	draw_textfield_group(name, (xx + wid - 128) + 8, yy, 128, 0, null, null, snapval, false, false, 0, true)
	
	textfocus = microani_arr[e_microani.CUSTOM]
	
	// Caption
	microani_set(name, null, window_busy = name + "min" || window_busy = name + "max" || slidermouseon, slidermouseon && mouse_left, false, false, 1, false)
	microani_update(window_busy = name + "min" || window_busy = name + "max" || slidermouseon, slidermouseon && mouse_left, window_busy = name + "min" || window_busy = name + "max", false, mouseon || textfocus)
	
	var labelcolor, labelalpha;
	labelcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	labelcolor = merge_color(labelcolor, c_accent, max(textfocus, microani_arr[e_microani.ACTIVE]))
	labelalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	labelalpha = lerp(labelalpha, a_accent, max(textfocus, microani_arr[e_microani.ACTIVE]))
	
	draw_set_font(font_label)
	draw_label(string_limit(text_get(name), wid - 128), xx, yy + (ui_small_height/2), fa_left, fa_middle, labelcolor, labelalpha)
	
	if (window_compact || app.panel_compact)
		return 0
	
	// Slider
	yy += 24
	
	linex = xx
	linewid = wid
	trackx = linex + 6
	trackwid = linewid - 12
	
	thumby = yy + thumbhei / 2
	
	minthumbpos = (window_busy = name + "min" ? meter_drag_value : minval)
	minthumbpos = trackx + floor(percent(minthumbpos, minrange, maxrange) * trackwid) - 6
	
	maxthumbpos = (window_busy = name + "max" ? meter_drag_value : maxval)
	maxthumbpos = trackx + floor(percent(maxthumbpos, minrange, maxrange) * trackwid) - 6
	
	minmouseon = app_mouse_box(minthumbpos, thumby - 10, 12, 20) && content_mouseon
	maxmouseon = app_mouse_box(maxthumbpos, thumby - 10, 12, 20) && content_mouseon
	
	// Click on thumbs
	if (slidermouseon && window_busy = "")
	{
		if (minmouseon || maxmouseon)
			mouse_cursor = cr_handpoint
		
		if (mouse_left_pressed) // Start dragging
		{
			if (minmouseon)
			{
				window_busy = name + "min"
				meter_drag_value = minval
			}
			else if (maxmouseon)
			{
				window_busy = name + "max"
				meter_drag_value = maxval
			}
			window_focus = name
		}
		
		if (mouse_right_pressed)
		{
			script_execute(minscript, mindef, false)
			script_execute(maxscript, maxdef, false)
		}
	}
	
	// Dragging
	if (window_busy = name + "min" || window_busy = name + "max")
	{
		mouse_cursor = cr_handpoint
		
		if (app.setting_unlimited_values)
			meter_drag_value = minrange + (mouse_x - linex) * (max(1, (maxrange - minrange)) / linewid)
		else
			meter_drag_value = clamp(minrange + (mouse_x - linex) * (max(1, (maxrange - minrange)) / linewid), minrange, maxrange)
		
		if (window_busy = name + "min")
		{
			var d = min(snap(meter_drag_value, snapval), maxval) - minval;
			if (d <> 0)
				script_execute(minscript, d, true)
		}
		else
		{
			var d = max(snap(meter_drag_value, snapval), minval) - maxval;
			if (d <> 0)
				script_execute(maxscript, d, true)
		}
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	// Clamp positions during drag
	if (window_busy = name + "min")
		minthumbpos = min(minthumbpos, maxthumbpos)
	if (window_busy = name + "max")
		maxthumbpos = max(minthumbpos, maxthumbpos)
	
	// Rail line
	var color, alpha;
	color = merge_color(c_text_tertiary, c_text_secondary, max(microani_arr[e_microani.HOVER], microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS]))
	color = merge_color(color, c_border, microani_arr[e_microani.DISABLED])
	alpha = lerp(a_text_tertiary, a_text_secondary, max(microani_arr[e_microani.HOVER], microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS]))
	alpha = lerp(alpha, a_border, microani_arr[e_microani.DISABLED])
	
	draw_box(linex, thumby - 1, minthumbpos - linex, 2, false, color, alpha)
	draw_box(maxthumbpos, thumby - 1, (linex + linewid) - maxthumbpos, 2, false, color, alpha)
	
	// Selected region
	color = merge_color(c_accent, c_text_tertiary, microani_arr[e_microani.DISABLED])
	alpha = merge_color(a_accent, a_text_tertiary, microani_arr[e_microani.DISABLED])
	draw_box(minthumbpos, thumby - 1, maxthumbpos - minthumbpos, 2, false, color, alpha)
	
	// Minimum dragger
	microani_set(name + "min", minscript, (window_busy = name + "min") || minmouseon, minmouseon && mouse_left, false)
	microani_update((window_busy = name + "min") || minmouseon, minmouseon && mouse_left, false)
	
	color = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
	color = merge_color(color, c_accent_pressed, max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS]))
	color = merge_color(color, c_text_tertiary, microani_arr[e_microani.DISABLED])
	alpha = lerp(1, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	draw_box(minthumbpos, thumby - 10, 12, 20, false, c_level_middle, 1)
	draw_box(minthumbpos, thumby - 10, 12, 20, false, color, alpha)
	draw_box_bevel(minthumbpos, thumby - 10, 12, 20, 1)
	draw_box_hover(minthumbpos, thumby - 10, 12, 20, microani_arr[e_microani.ACTIVE])
	
	// Maximum dragger
	microani_set(name + "max", maxscript, (window_busy = name + "max") || maxmouseon, maxmouseon && mouse_left, false)
	microani_update((window_busy = name + "max") || maxmouseon, maxmouseon && mouse_left, false)
	
	color = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
	color = merge_color(color, c_accent_pressed, max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS]))
	color = merge_color(color, c_text_tertiary, microani_arr[e_microani.DISABLED])
	alpha = lerp(1, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	draw_box(maxthumbpos, thumby - 10, 12, 20, false, c_level_middle, 1)
	draw_box(maxthumbpos, thumby - 10, 12, 20, false, color, alpha)
	draw_box_bevel(maxthumbpos, thumby - 10, 12, 20, 1)
	draw_box_hover(maxthumbpos, thumby - 10, 12, 20, microani_arr[e_microani.ACTIVE])
}
