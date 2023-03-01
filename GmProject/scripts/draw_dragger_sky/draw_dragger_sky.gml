/// draw_dragger_sky(name, x, y, value, default, script, tbx, time)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg default
/// @arg script
/// @arg tbx
/// @arg time

function draw_dragger_sky(name, xx, yy, value, def, script, tbx, time)
{
	var wid, hei, capwidth, caption, fieldx, dragmouseon, snapval;
	wid = dragger_width
	hei = ui_small_height
	capwidth = dw - wid
	snapval = 1
	
	draw_set_font(font_label)
	
	caption = string_limit(text_get(name), capwidth)
	
	if (xx + wid + capwidth < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	{
		if (textbox_jump)
			ds_list_add(textbox_list, [tbx, content_tab, yy, content_y, content_height])
		
		return 0
	}
	
	context_menu_area(xx, yy, wid + capwidth, hei, "contextmenuvalue", value, time ? e_context_type.TIME : e_context_type.NUMBER, script, def)
	
	fieldx = xx + capwidth
	dragmouseon = app_mouse_box(fieldx, yy, wid, hei) && content_mouseon && (window_focus != string(tbx))
	
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
			if (app_mouse_box(fieldx, yy, wid, hei))
			{
				if (!time)
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
		dragger_drag_value += (mouse_x - mouse_click_x) * dragger_multiplier
		window_mouse_set(mouse_click_x, mouse_click_y)
		
		var d = snap(dragger_drag_value, snapval) - value;
		
		if (d <> 0)
		{
			script_execute(script, d, true)
			
			if (time)
				tbx.text = rotation_get_time(value + d)
			else
				tbx.text = string_decimals(value + d)
		}
		
		if (!mouse_left)
		{
			window_busy = ""
			app_mouse_clear()
		}
	}
	
	if (draw_inputbox(name, fieldx, yy, wid, hei, string(def), tbx, null, false, false, font_digits, e_inputbox.RIGHT) && script != null)
	{
		if (time)
			script_execute(script, time_get_rotation(tbx.text), false)
		else
			script_execute(script, clamp(string_get_real(tbx.text, 0), -no_limit, no_limit), false)
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
	
	draw_label(caption, xx, yy + hei/2, fa_left, fa_middle, labelcolor, labelalpha, font_label)
	
	// Idle
	if (window_busy != name + "drag" && window_busy != name + "press" && window_focus != string(tbx))
	{
		if (time)
			tbx.text = rotation_get_time(value)
		else
			tbx.text = string_decimals(value)
	}
}
