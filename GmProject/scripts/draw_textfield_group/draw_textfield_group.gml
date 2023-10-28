/// draw_textfield_group(name, x, y, width, multiplier, min, max, snap, [showcaption, [stack, [colortype, [drag, [update_values]]]]])
/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg snap
/// @arg [showcaption
/// @arg [stack
/// @arg [colortype
/// @arg [drag
/// @arg [update_values]]]]

function draw_textfield_group(name, xx, yy, wid, mul, minval, maxval, snapval, showcaption = false, stack = true, colortype = 0, drag = true, textfield_update = true)
{
	var vertical, fieldx, fieldy, fieldwid, fieldupdate, hei;
	
	vertical = (app.panel_compact) && stack
	fieldx = xx
	fieldy = yy
	fieldwid = vertical ? wid : (wid/textfield_amount)
	fieldupdate = undefined
	hei = (vertical ? (ui_small_height * textfield_amount) : ui_small_height) + ((label_height + 8) * showcaption)
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	{
		textfield_group_reset()
		return 0
	}
	
	var dragw, mouseon;
	
	mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	
	// Last textfield has 'active' animation, will need that for label color and border
	microani_set(string(textfield_textbox[textfield_amount - 1]) + textfield_name[textfield_amount - 1], textfield_script[textfield_amount - 1], false, false, false, false, 1, false)
	
	var active = current_microani.custom;
	microani_set(name, null, mouseon || active, false, false)
	microani_update(mouseon || active, false, false)
	
	if (showcaption)
	{
		draw_set_font(font_label)
		draw_label(string_limit(text_get(name), dw), xx, yy, fa_left, fa_top, c_text_secondary, a_text_secondary)
		yy += (label_height + 8)
	}
	
	hei = ui_small_height
	fieldx = xx
	fieldy = yy
	dragw = 16
	
	draw_box(xx, yy, wid, (vertical ? textfield_amount * hei : hei), false, c_level_top, draw_get_alpha())
	
	// Draw field backgrounds
	if (vertical)
		draw_outline(fieldx, fieldy, wid, textfield_amount * hei, 1, c_border, a_border, true)
	else
		draw_outline(fieldx, fieldy, wid, hei, 1, c_border, a_border, true)
	
	draw_set_font(font_label)
	for (var i = 0; i < textfield_amount; i++)
	{	
		if (i > 0)
		{
			if (vertical)
				draw_box(fieldx + 1, fieldy - 1, fieldwid - 2, 1, false, c_border, a_border)
			else
				draw_box(fieldx, fieldy + 1, 1, hei - 2, false, c_border, a_border)
		}
		
		if (vertical)
			fieldy += hei
		else
			fieldx += fieldwid
		
		// Get max dragging width from labels
		dragw = max(dragw, string_width(text_get(textfield_caption[i] != null ? textfield_caption[i] : textfield_name[i])) + 16)
	}
	
	fieldx = xx
	fieldy = yy
	
	// Draw fields
	var boxwid, boxhei, boxy, update;
	active = false
	
	for (var i = 0; i < textfield_amount; i++)
	{
		axis_edit = textfield_axis[i]
		boxhei = hei
		boxwid = fieldwid
		boxy = fieldy
		
		if (i < (textfield_amount - 1) && !vertical)
			boxwid += 1
		
		if (i != 0 && vertical)
		{
			boxhei += 1
			boxy -= 1
		}
		
		mouseon = app_mouse_box(fieldx, boxy, boxwid, boxhei) && content_mouseon
		
		if (textfield_min != null)
		{
			minval = textfield_min[i]
			maxval = textfield_max[i]
		}
		
		context_menu_area(fieldx, boxy, boxwid, boxhei, "contextmenuvalue", textfield_value[i], e_context_type.NUMBER, textfield_script[i], textfield_default[i])
		
		microani_set(string(textfield_textbox[i]) + textfield_name[i], textfield_script[i], mouseon || window_focus = string(textfield_textbox[i]), false, (mouseon && mouse_left) || (window_focus = string(textfield_textbox[i])))
		
		// Draw base button
		var focus, linecolor, linealpha;
		focus = max(microani_arr[e_microani.PRESS], microani_arr[e_microani.ACTIVE])
		linecolor = merge_color(c_border, c_text_tertiary, microani_arr[e_microani.HOVER])
		linecolor = merge_color(linecolor, c_accent, focus)
		linealpha = lerp(0, a_text_tertiary, microani_arr[e_microani.HOVER])
		linealpha = lerp(linealpha, a_accent, focus)
		
		var labelcolor, labelalpha;
		
		if (colortype > 0)
		{
			if (colortype = 1) // XYZ colors
			{
				if (axis_edit = X)
					labelcolor = c_axisred
				else if (axis_edit = Y)
					labelcolor = (setting_z_is_up ? c_axisgreen : c_axisblue)
				else
					labelcolor = (setting_z_is_up ? c_axisblue : c_axisgreen)
			}
			else if (colortype = 2) // XYZ alt. colors
			{
				if (axis_edit = X)
					labelcolor = c_axiscyan
				else if (axis_edit = Y)
					labelcolor = (setting_z_is_up ? c_axisyellow : c_axismagenta)
				else
					labelcolor = (setting_z_is_up ? c_axismagenta : c_axisyellow)
			}
			else if (colortype = 3) // RGB
			{
				if (i = 0)
					labelcolor = c_axisred
				else if (i = 1)
					labelcolor = c_axisgreen
				else
					labelcolor = c_axisblue
			}
			
			labelalpha = 1
		}
		else
		{
			labelcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
			labelcolor = merge_color(labelcolor, c_accent, focus)
			
			labelalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
			labelalpha = lerp(labelalpha, a_accent, focus)
		}
		
		if (textfield_icon[i] = null)
			draw_label(text_get(textfield_caption[i] != null ? textfield_caption[i] : textfield_name[i]), fieldx + 8, boxy + ceil(boxhei/2), fa_left, fa_middle, labelcolor, labelalpha, font_label)
		else
			draw_image(spr_icons, textfield_icon[i], floor(fieldx + 14), boxy + ceil(boxhei/2), 1, 1, c_text_secondary, a_text_secondary)
		
		// Outline
		draw_outline(fieldx, boxy, boxwid, boxhei, 1, c_level_middle, max(focus, microani_arr[e_microani.HOVER]), true)
		draw_outline(fieldx, boxy, boxwid, boxhei, 1, linecolor, linealpha, true)
		
		draw_box_hover(fieldx, boxy, boxwid, boxhei, microani_arr[e_microani.PRESS])
		
		if (textfield_value[i] < minval || textfield_value[i] > maxval)
			draw_box(fieldx, boxy, boxwid, boxhei, false, c_error, a_accent_overlay)
		else if ((abs(maxval) + abs(minval)) < 100000)
		{
			// Idle
			var perc = percent(textfield_value[i], minval, maxval);
			draw_box(fieldx, boxy, boxwid * perc, boxhei, false, c_accent_hover, a_accent_overlay)
		}
		
		active = (active || window_focus = string(textfield_textbox[i]))
		microani_update(mouseon, mouseon && mouse_left, window_focus = string(textfield_textbox[i]) || (window_busy = textfield_name[i] + "drag") || (window_busy = textfield_name[i] + "press"), false, active)
		
		// Textbox
		draw_set_font(font_digits)
		
		var update = textbox_draw(textfield_textbox[i], fieldx + dragw, boxy + ceil(boxhei/2) - 7, boxwid - (8 + dragw), 18, true, true);
		
		// Textbox press
		if (app_mouse_box(fieldx + dragw, boxy, boxwid - (8 + dragw), boxhei) && content_mouseon && window_focus != string(textfield_textbox[i]))
		{
			if (mouse_left_released)
			{
				window_focus = string(textfield_textbox[i])
				window_busy = ""
			}
		}
		
		// Drag
		if (app_mouse_box(fieldx, boxy, boxwid, boxhei) && content_mouseon && window_focus != string(textfield_textbox[i]) && drag)
		{
			mouse_cursor = cr_size_we
	
			if (mouse_left_pressed)
				window_busy = textfield_name[i] + "press"
		}
		
		// Mouse pressed
		if (window_busy = textfield_name[i] + "press")
		{
			mouse_cursor = cr_size_we
			
			if (!mouse_left)
			{
				window_focus = string(textfield_textbox[i])
				window_busy = ""
				app_mouse_clear()
			}
			else if (mouse_dx != 0)
			{
				dragger_drag_value = textfield_value[i]
				window_busy = textfield_name[i] + "drag" // Start dragging
			}
		}
		
		// Is dragging
		if (window_busy = textfield_name[i] + "drag")
		{ 
			mouse_cursor = cr_none
			dragger_drag_value += (mouse_x - mouse_click_x) * (textfield_mul[i] = null ? mul : textfield_mul[i]) * dragger_multiplier
			window_mouse_set(mouse_click_x, mouse_click_y)
			
			var d;
			
			if (app.setting_unlimited_values)
				d = snap(dragger_drag_value, snapval) - textfield_value[i]
			else
				d = clamp(snap(dragger_drag_value, snapval), minval, maxval) - textfield_value[i]
			
			if (d <> 0 && textfield_script[i] != null && textfield_update)
				script_execute(textfield_script[i], d, true)
			else
			{
				textfield_textbox[i].text = string_decimals(textfield_value[i] + d)
				fieldupdate = textfield_textbox[i]
			}
			
			if (!mouse_left)
			{
				window_busy = ""
				app_mouse_clear()
				
				script_execute(textfield_script[i], d, true)
			}
		}
		
		// Textbox input update
		if (update)
		{
			var val = eval(textfield_textbox[i].text, textfield_default[i]);
			
			if (textfield_script[i] != null)
				script_execute(textfield_script[i], app.setting_unlimited_values ? snap(val, snapval) : clamp(snap(val, snapval), minval, maxval), false)
			else
				fieldupdate = val
		}
		
		// Idle update
		if (window_busy != textfield_name[i] + "press" && window_focus != string(textfield_textbox[i]) && fieldupdate = undefined)
			textfield_textbox[i].text = string_decimals(textfield_value[i])
		
		if (vertical)
			fieldy += hei
		else
			fieldx += fieldwid
	}
	
	textfield_group_reset()
	
	return fieldupdate
}
