/// toast_draw(toast)
/// @arg toast
/// @desc Draws a notification toast

function toast_draw(toast)
{
	var color, wid, hei;
	color = setting_theme.toast_color[toast.variant]
	wid = 0
	hei = 0
	microani_prefix = string(toast)
	
	content_x = floor(window_width/2 - toast.toast_width/2)
	content_y = toast.toast_y
	content_width = toast.toast_width
	content_height = toast.toast_height
	
	content_mouseon = app_mouse_box(content_x, content_y, content_width, content_height) && (toast.remove_alpha = 1)
	
	if (content_mouseon)
		toast_mouseon = true
	
	dx_start = content_x
	dy_start = content_y
	dx = dx_start
	dy = dy_start
	dw = content_width
	dh = content_height
	
	// Background
	draw_box(dx, dy, dw, dh, false, c_level_top, 1)
	draw_outline(dx, dy, dw, dh, 1, color, 1, true)
	draw_dropshadow(dx, dy, dw, dh, c_black, 1)
	
	// Pause countdown
	if (toast_mouseon)
		toast.time_created += delta_time / 1000
	
	// Dismiss bar
	if (toast.dismiss_time != no_limit)
		draw_box(dx, dy + dh - 3, dw * (1 - ((current_time - toast.time_created) / (toast.dismiss_time * 1000))), 2, false, color, 1)
	
	dx = dx_start + 8
	dy = dy_start + 8
	
	// Icon
	wid = 40
	draw_image(spr_icons, toast.icon, dx + 12, content_y + content_height/2, 1, 1, color, 1)
	dx += 32
	
	// Text
	draw_set_font(font_value)
	draw_label(toast.text, dx, content_y + content_height/2, fa_left, fa_middle, c_text_main, a_text_main)
	
	wid += string_width(toast.text) + 16
	dx += string_width(toast.text) + 16
	
	// Actions
	if (ds_list_size(toast.actions) > 0)
	{
		draw_set_font(font_label)
		var capwid, multiaction, actiony;
		capwid = 0
		multiaction = ds_list_size(toast.actions) > 4
		actiony = content_y + (!multiaction * 4)
		
		for (var i = 0; i < ds_list_size(toast.actions); i += 3)
			capwid = max(capwid, 24 + string_width(text_get(toast.actions[|i])))
		
		for (var i = 0; i < ds_list_size(toast.actions); i += 3)
		{
			if (draw_button_label(toast.actions[|i], dx, actiony, capwid, null, e_button.TERTIARY, null, e_anchor.LEFT))
			{
				toast_script = toast.actions[|i + 1]
				toast_script_value = toast.actions[|i + 2]
				toast.remove = true
			}
			
			if (multiaction && i != 0)
				draw_divide(dx, actiony, capwid)
			
			actiony += 32
		}
		
		// Left border
		if (multiaction)
			draw_divide_vertical(dx, content_y + 1, content_height - 2)
		
		wid += capwid + (4 * !multiaction)
		hei = multiaction ? ((ds_list_size(toast.actions)/3) * 32) : 40
	}
	else // Close button
	{
		if (draw_button_icon(string(toast) + "close", dx, dy, 24, 24, false, icons.CLOSE, null, false))
			toast.remove = true
		
		hei = 40
		wid += 32
	}
	
	toast.toast_height = hei
	toast.toast_width = wid
	
	// Time out dismiss
	if (toast.dismiss_time != no_limit && ((current_time - toast.time_created) > (toast.dismiss_time * 1000)))
		toast.remove = true
	
	microani_prefix = ""
}
