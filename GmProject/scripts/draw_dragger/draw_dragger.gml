/// draw_dragger(name, x, y, width, value, multiplier, min, max, default, snap, textbox, script, [captionwidth, [showcaption, [disabled, [tip]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg value
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg default
/// @arg snap
/// @arg textbox
/// @arg script
/// @arg [captionwidth
/// @arg [showcaption
/// @arg [disabled
/// @arg [tip]]]]

function draw_dragger(name, xx, yy, wid, value, mul, minval, maxval, def, snapval, tbx, script, capwidth = null, showcaption = true, disabled = false, tip = "")
{
	var caption, hei, fieldx, dragmouseon;
	
	hei = ui_small_height
	
	if (capwidth = null && showcaption)
		capwidth = dw - wid
	else if (!showcaption)
		capwidth = 0
	
	draw_set_font(font_label)
	
	if (capwidth > 0)
		caption = string_limit(text_get(name), min(capwidth, dw - wid))
	else
		caption = string_limit(text_get(name), dw - wid)
	
	if (xx + wid + capwidth < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	{
		if (textbox_jump)
			ds_list_add(textbox_list, [tbx, content_tab, yy, content_y, content_height])
		
		return 0
	}
	
	if (!disabled)
		context_menu_area(xx, yy, wid + capwidth, hei, "contextmenuvalue", value, e_context_type.NUMBER, script, def)
	
	fieldx = xx + capwidth
	
	dragmouseon = app_mouse_box(fieldx, yy, wid, hei) && content_mouseon && (window_focus != string(tbx)) && !disabled
	
	// Drag
	if (dragmouseon && mouse_left_pressed)
		window_focus = name + "press"
	
	// Mouse pressed
	if (window_focus = name + "press")
	{
		mouse_cursor = cr_size_we
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
			
			// Select textbox
			if (app_mouse_box(fieldx, yy, wid, hei) && !disabled)
			{
				tbx.text = string_decimals(value)
				window_focus = string(tbx)
				window_busy = ""
			}
		}
		else if (mouse_dx != 0)
		{
			dragger_drag_value = value
			window_busy = name + "drag" // Start dragging
			window_focus = ""
		}
	}
	
	// Is dragging
	if (window_busy = name + "drag")
	{
		mouse_cursor = cr_none
		dragger_drag_value += (mouse_x - mouse_click_x) * mul * dragger_multiplier
		window_mouse_set(mouse_click_x, mouse_click_y)
		
		var d;
		
		if (app.setting_unlimited_values)
			d = snap(dragger_drag_value, snapval) - value;
		else
			d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - value;
		
		if (d <> 0)
		{
			script_execute(script, d, true)
			tbx.text = string_decimals(value + d)
		}
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	if (draw_inputbox(name, fieldx, yy, wid, hei, string(def), tbx, null, disabled, false, font_digits, e_inputbox.RIGHT) && script != null)
	{
		var val = eval(tbx.text, def);
		script_execute(script, app.setting_unlimited_values ? snap(val, snapval) : clamp(snap(val, snapval), minval, maxval), false)
	}
	
	if (value < minval || value > maxval)
		draw_box(fieldx, yy, wid, hei, false, c_error, a_accent_overlay)
	else if ((abs(maxval) + abs(minval)) < 100000)
	{
		// Idle
		var perc = percent(value, minval, maxval);
		draw_box(fieldx, yy, wid * perc, hei, false, c_accent_hover, a_accent_overlay)
	}
	
	if (window_busy = name + "drag")
		current_microani.active.value = true
	
	// Set cursor
	if (dragmouseon)
		mouse_cursor = cr_size_we
	
	// Use microanimation from inputbox to determine color
	var labelcolor, labelalpha;
	labelcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	labelcolor = merge_color(labelcolor, c_accent, microani_arr[e_microani.ACTIVE])
	labelcolor = merge_color(labelcolor, c_text_tertiary, microani_arr[e_microani.DISABLED])
	
	labelalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	labelalpha = lerp(labelalpha, a_accent, microani_arr[e_microani.ACTIVE])
	labelalpha = lerp(labelalpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	if (showcaption)
	{
		draw_label(caption, xx, yy + hei/2, fa_left, fa_middle, labelcolor, labelalpha, font_label)
		
		if (xx + string_width(caption) + 28 < fieldx)
			draw_help_circle(tip, xx + string_width(caption) + 4, yy + (hei/2) - 10, disabled)
	}
	
	// Idle
	if (window_busy != name + "drag" && window_busy != name + "press" && window_focus != string(tbx))
		tbx.text = string_decimals(value)
}
