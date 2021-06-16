/// draw_dragger(name, x, y, width, value, multiplier, min, max, default, snap, textbox, script, [captionwidth, [showcaption, [disabled]]])
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
/// @arg [disabled]]]

function draw_dragger()
{
	var name, xx, yy, wid, value, mul, minval, maxval, def, snapval, tbx, script, capwidth, showcaption, disabled;
	var caption, hei, fieldx, dragmouseon;
	name = argument[0]
	xx = argument[1]
	yy = argument[2]
	wid = argument[3]
	value = argument[4]
	mul = argument[5]
	minval = argument[6]
	maxval = argument[7]
	def = argument[8]
	snapval = argument[9]
	tbx = argument[10]
	script = argument[11]
	
	draw_set_font(font_label)
	caption = string_limit(text_get(name), dw - wid)
	
	if (argument_count > 12)
		capwidth = argument[12]
	else
		capwidth = null
	
	if (argument_count > 13)
		showcaption = argument[13]
	else
		showcaption = true
	
	if (argument_count > 14)
		disabled = argument[14]
	else
		disabled = false
	
	hei = 24
	
	if (capwidth = null && showcaption)
		capwidth = dw - wid
	else if (!showcaption)
		capwidth = 0
	
	if (xx + wid + capwidth < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
		return 0
	
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
		
		var d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - value;
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
	
	if (draw_inputbox(name, fieldx, yy, wid, hei, string(def), tbx, null, disabled, false, font_digits, e_inputbox.RIGHT))
	{
		var val = eval(tbx.text, def);
		script_execute(script, clamp(snap(val, snapval), minval, maxval), false)
	}
	
	if (window_busy = name + "drag")
		current_mcroani.value = true
	
	// Set cursor
	if (dragmouseon)
		mouse_cursor = cr_size_we
	
	// Use microanimation from inputbox to determine color
	var labelcolor, labelalpha;
	labelcolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
	labelcolor = merge_color(labelcolor, c_accent, mcroani_arr[e_mcroani.ACTIVE])
	labelcolor = merge_color(labelcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	
	labelalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
	labelalpha = lerp(labelalpha, a_accent, mcroani_arr[e_mcroani.ACTIVE])
	labelalpha = lerp(labelalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	
	if (showcaption)
		draw_label(caption, xx, yy + hei/2, fa_left, fa_middle, labelcolor, labelalpha, font_label)
	
	// Idle
	if (window_busy != name + "drag" && window_busy != name + "press" && window_focus != string(tbx))
		tbx.text = string_decimals(value)
}
