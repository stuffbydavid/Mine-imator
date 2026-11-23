/// @arg name
/// @arg x
/// @arg y
/// @arg width
/// @arg multiplier
/// @arg min
/// @arg max
/// @arg snap
/// @arg [showcaption]
/// @arg [stack]
/// @arg [colortype]
/// @arg [drag]
/// @arg [updatevalues]

function draw_textfield_group(name, xx, yy, wid, mul, minval, maxval, snapval, showcaption = false, stack = true, colortype = 0, drag = true, updatevalues = true)
{
	var vertical, fieldx, fieldy, fieldwid, fieldupdate, hei, amount, field;
	amount = array_length(textfield_group)
	if (amount = 0)
		return 0

	vertical = (app.panel_compact && stack)
	fieldx = xx
	fieldy = yy
	fieldwid = vertical ? wid : (wid/amount)
	fieldupdate = undefined
	hei = (vertical ? real(ui_small_height * amount) : ui_small_height) + ((label_height + 8) * showcaption)
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
	{
		textfield_group = []
		return 0
	}
	
	var dragw, mouseon;
	
	mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	
	// Last textfield has 'active' animation, will need that for label color and border
	field = textfield_group[amount - 1]
	microani_set(string(field[e_textfield_group.TEXTBOX]) + field[e_textfield_group.NAME], field[e_textfield_group.SCRIPT], false, false, false, false, 1, false)
	
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
	
	draw_box(xx, yy, wid, (vertical ? amount * hei : hei), false, c_input_background, draw_get_alpha())
	
	// Draw field backgrounds
	if (vertical)
		draw_outline(fieldx, fieldy, wid, amount * hei, 1, c_border, a_border, true)
	else
		draw_outline(fieldx, fieldy, wid, hei, 1, c_border, a_border, true)
	
	draw_set_font(font_label)
	for (var i = 0; i < amount; i++)
	{
		field = textfield_group[i]

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
		dragw = max(dragw, string_width(text_get(field[e_textfield_group.CAPTION] != null ? field[e_textfield_group.CAPTION] : field[e_textfield_group.NAME])) + 16)
	}
	
	fieldx = xx
	fieldy = yy
	
	// Draw fields
	var boxwid, boxhei, boxy, update, fieldmin, fieldmax;
	active = false
	
	for (var i = 0; i < amount; i++)
	{
		field = textfield_group[i]
		axis_edit = field[e_textfield_group.AXIS]
		boxhei = hei
		boxwid = fieldwid
		boxy = fieldy
		
		if (i < (amount - 1) && !vertical)
			boxwid += 1
		
		if (i != 0 && vertical)
		{
			boxhei += 1
			boxy -= 1
		}
		
		mouseon = app_mouse_box(fieldx, boxy, boxwid, boxhei) && content_mouseon
		
		fieldmin = minval
		fieldmax = maxval
		if (field[e_textfield_group.MIN] != null)
		{
			fieldmin = field[e_textfield_group.MIN]
			fieldmax = field[e_textfield_group.MAX]
		}
		
		context_menu_area(fieldx, boxy, boxwid, boxhei, "context_menu/value", field[e_textfield_group.VALUE], e_context_type.NUMBER, field[e_textfield_group.SCRIPT], field[e_textfield_group.DEFAULT])
		
		microani_set(string(field[e_textfield_group.TEXTBOX]) + field[e_textfield_group.NAME], field[e_textfield_group.SCRIPT], mouseon || window_focus = string(field[e_textfield_group.TEXTBOX]), false, (mouseon && mouse_left) || (window_focus = string(field[e_textfield_group.TEXTBOX])))
		
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
		
		if (field[e_textfield_group.ICON] = null)
			draw_label(text_get(field[e_textfield_group.CAPTION] != null ? field[e_textfield_group.CAPTION] : field[e_textfield_group.NAME]), fieldx + 8, boxy + ceil(boxhei/2), fa_left, fa_middle, labelcolor, labelalpha, font_label)
		else
			draw_image(spr_icons, field[e_textfield_group.ICON], floor(fieldx + 14), boxy + ceil(boxhei/2), 1, 1, c_text_secondary, a_text_secondary)
		
		// Outline
		draw_outline(fieldx, boxy, boxwid, boxhei, 1, c_level_middle, max(focus, microani_arr[e_microani.HOVER]), true)
		draw_outline(fieldx, boxy, boxwid, boxhei, 1, linecolor, linealpha, true)
		
		draw_box_hover(fieldx, boxy, boxwid, boxhei, microani_arr[e_microani.PRESS])
		
		if (field[e_textfield_group.VALUE] < fieldmin || field[e_textfield_group.VALUE] > fieldmax)
			draw_box(fieldx, boxy, boxwid, boxhei, false, c_error, a_accent_overlay)
		else if ((abs(fieldmax) + abs(fieldmin)) < 100000)
		{
			// Idle
			var perc = percent(field[e_textfield_group.VALUE], fieldmin, fieldmax);
			draw_box(fieldx, boxy, boxwid * perc, boxhei, false, c_accent_hover, a_accent_overlay)
		}
		
		active = (active || window_focus = string(field[e_textfield_group.TEXTBOX]))
		microani_update(mouseon, mouseon && mouse_left, window_focus = string(field[e_textfield_group.TEXTBOX]) || (window_busy = field[e_textfield_group.NAME] + "/drag") || (window_busy = field[e_textfield_group.NAME] + "/press"), false, active)
		
		// Textbox
		draw_set_font(font_digits)
		
		update = textbox_draw(field[e_textfield_group.TEXTBOX], fieldx + dragw, boxy + ceil(boxhei/2) - 7, boxwid - (8 + dragw), 18, true, true)
		
		// Textbox press
		if (app_mouse_box(fieldx + dragw, boxy, boxwid - (8 + dragw), boxhei) && content_mouseon && window_focus != string(field[e_textfield_group.TEXTBOX]))
		{
			if (mouse_left_released)
			{
				window_focus = string(field[e_textfield_group.TEXTBOX])
				window_busy = ""
			}
		}
		
		// Drag
		if (app_mouse_box(fieldx, boxy, boxwid, boxhei) && content_mouseon && window_focus != string(field[e_textfield_group.TEXTBOX]) && drag)
		{
			mouse_cursor = cr_size_we
	
			if (mouse_left_pressed)
				window_busy = field[e_textfield_group.NAME] + "/press"
		}
		
		// Mouse pressed
		if (window_busy = field[e_textfield_group.NAME] + "/press")
		{
			mouse_cursor = cr_size_we
			
			if (!mouse_left)
			{
				window_focus = string(field[e_textfield_group.TEXTBOX])
				window_busy = ""
				app_mouse_clear()
			}
			else if (mouse_dx != 0)
			{
				dragger_drag_value = field[e_textfield_group.VALUE]
				window_busy = field[e_textfield_group.NAME] + "/drag" // Start dragging
			}
		}
		
		// Is dragging
		if (window_busy = field[e_textfield_group.NAME] + "/drag")
		{ 
			mouse_cursor = cr_none
			dragger_drag_value += (mouse_x - mouse_click_x) * (field[e_textfield_group.MUL] = null ? mul : field[e_textfield_group.MUL]) * dragger_multiplier
			window_mouse_set(mouse_click_x, mouse_click_y)
			
			var d;
			
			if (app.setting_unlimited_values)
				d = snap(dragger_drag_value, snapval) - field[e_textfield_group.VALUE]
			else
				d = clamp(snap(dragger_drag_value, snapval), fieldmin, fieldmax) - field[e_textfield_group.VALUE]
			
			if (d <> 0 && field[e_textfield_group.SCRIPT] != null && updatevalues)
				script_execute(field[e_textfield_group.SCRIPT], d, true)
			else
			{
				field[e_textfield_group.TEXTBOX].text = string_decimals(field[e_textfield_group.VALUE] + d)
				fieldupdate = field[e_textfield_group.TEXTBOX]
			}
			
			if (!mouse_left)
			{
				window_busy = ""
				app_mouse_clear()
				
				script_execute(field[e_textfield_group.SCRIPT], d, true)
			}
		}
		
		// Textbox input update
		if (update)
		{
			var val = eval(field[e_textfield_group.TEXTBOX].text, field[e_textfield_group.DEFAULT]);
			
			if (field[e_textfield_group.SCRIPT] != null)
				script_execute(field[e_textfield_group.SCRIPT], app.setting_unlimited_values ? snap(val, snapval) : clamp(snap(val, snapval), fieldmin, fieldmax), false)
			else
				fieldupdate = val
		}
		
		// Idle update
		if (window_busy != field[e_textfield_group.NAME] + "/press" && window_focus != string(field[e_textfield_group.TEXTBOX]) && is_undefined(fieldupdate))
			field[e_textfield_group.TEXTBOX].text = string_decimals(field[e_textfield_group.VALUE])
		
		if (vertical)
			fieldy += hei
		else
			fieldx += fieldwid
	}
	
	textfield_group = []
	
	return fieldupdate
}
