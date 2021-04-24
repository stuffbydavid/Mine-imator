/// draw_button_color(name, x, y, w, color, default, hslmode, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg w
/// @arg color
/// @arg default
/// @arg hslmode
/// @arg script

function draw_button_color(name, xx, yy, w, color, def, hslmode, script)
{
	var textx, textw, h, mouseon, mouseclick, active;
	textx = xx
	textw = w
	
	h = 24
	yy += (label_height + 8)
	
	active = (settings_menu_name = "colorpicker" && colorpicker.value_name = name)
	mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon
	mouseclick = mouseon && mouse_left
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	context_menu_area(xx, yy, w, h, "contextmenuvalue", color, e_context_type.COLOR, script, def)
	microani_set(name, script, mouseon, mouseclick, active, false, 1, true)
	
	// Draw button
	var col, alpha, labelcolor, labelalpha;
	
	// Fill
	col = merge_color(0, c_overlay, mcroani_arr[e_mcroani.HOVER])
	col = merge_color(col, c_accent_overlay, mcroani_arr[e_mcroani.ACTIVE])
	alpha = lerp(0, a_overlay, mcroani_arr[e_mcroani.HOVER])
	alpha = lerp(alpha, a_accent_overlay, mcroani_arr[e_mcroani.ACTIVE])
	draw_box(xx, yy, w, h, false, c_level_top, 1)
	draw_box(xx, yy, w, h, false, col, alpha)
	
	// Fill border
	col = merge_color(c_border, c_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	col = merge_color(col, c_accent, mcroani_arr[e_mcroani.ACTIVE])
	alpha = lerp(a_border, a_text_tertiary, mcroani_arr[e_mcroani.HOVER])
	alpha = lerp(alpha, a_accent, mcroani_arr[e_mcroani.ACTIVE])
	draw_outline(xx, yy, w, h, 1, col, alpha, true)
	
	// Color
	draw_box(xx + 4, yy + 4, w - 8, h - 8, false, color, 1)
	draw_outline(xx + 4, yy + 4, w - 8, h - 8, 1, c_border, a_border, 1)
	
	// Hover
	draw_box_hover(xx, yy, w, h, mcroani_arr[e_mcroani.HOVER])
	
	// Label
	labelcolor = merge_color(c_text_secondary, c_text_main, mcroani_arr[e_mcroani.HOVER])
	labelcolor = merge_color(labelcolor, c_accent, mcroani_arr[e_mcroani.ACTIVE])
	labelcolor = merge_color(labelcolor, c_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	
	labelalpha = lerp(a_text_secondary, a_text_main, mcroani_arr[e_mcroani.HOVER])
	labelalpha = lerp(labelalpha, a_accent, mcroani_arr[e_mcroani.ACTIVE])
	labelalpha = lerp(labelalpha, a_text_tertiary, mcroani_arr[e_mcroani.DISABLED])
	
	draw_set_font(font_label)
	draw_label(string_limit(text_get(name), w - 8), xx, yy - (label_height + 8), fa_left, fa_top, labelcolor, labelalpha)
	
	microani_update(mouseon, mouseclick, active || (mouseon && mouse_left), false)
	
	if (mouseon && mouse_left_released)
	{
		colorpicker_show(name, color, def, script, xx, yy, w, h)
		
		if (hslmode)
			colorpicker.mode = "hsl"
	}
}
