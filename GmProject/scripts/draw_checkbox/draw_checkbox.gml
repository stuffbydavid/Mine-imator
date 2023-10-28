/// draw_checkbox(name, xx, yy, active, script, [tip])
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script
/// @arg tip

function draw_checkbox(name, xx, yy, active, script, tip = "")
{
	var text, w, h, pressed;
	text = text_get(name)
	
	draw_set_font(font_label)
	
	w = 32 + string_width(text)
	h = ui_small_height
	
	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
		return 0
	
	// Mouse
	var mouseon, mouseclick;
	mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon && (window_busy = "")
	mouseclick = mouseon && mouse_left
	
	pressed = false
	
	if (mouseon)
	{
		if (mouse_left || mouse_left_released)
			pressed = true
		
		mouse_cursor = cr_handpoint
	}
	
	// Set micro animation before drawing
	microani_set(name, script, mouseon, mouseclick, active)
	
	var checkboxx, checkboxy;
	checkboxx = xx
	checkboxy = yy + (h/2) - 8
	
	var offcolor, offalpha, oncolor, onalpha, color, alpha;
	offcolor = merge_color(c_text_secondary, c_text_main, microani_arr[e_microani.HOVER])
	offcolor = merge_color(offcolor, c_accent, microani_arr[e_microani.PRESS])
	offalpha = lerp(a_text_secondary, a_text_main, microani_arr[e_microani.HOVER])
	offalpha = lerp(offalpha, a_accent, microani_arr[e_microani.PRESS])
	
	oncolor = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
	oncolor = merge_color(oncolor, c_accent_pressed, microani_arr[e_microani.PRESS])
	onalpha = lerp(a_accent, a_accent_hover, microani_arr[e_microani.HOVER])
	onalpha = lerp(onalpha, a_accent_pressed, microani_arr[e_microani.PRESS])
	
	color = merge_color(offcolor, oncolor, microani_arr[e_microani.ACTIVE])
	alpha = lerp(offalpha, onalpha, microani_arr[e_microani.ACTIVE])
	
	color = merge_color(color, c_text_tertiary, microani_arr[e_microani.DISABLED])
	alpha = lerp(alpha, a_text_tertiary, microani_arr[e_microani.DISABLED])
	
	// Draw checkbox
	draw_outline(checkboxx, checkboxy, 16, 16, 2 + (6 * microani_arr[e_microani.ACTIVE]), color, alpha, true)
	draw_image(spr_checkbox_tick, 0, checkboxx + 8, checkboxy + 8, 1, 1, c_level_middle, 1 * microani_arr[e_microani.ACTIVE])
	
	// Draw hover outline
	draw_box_hover(checkboxx, checkboxy, 16, 16, microani_arr[e_microani.PRESS])
	
	// Label
	var shortlabel = string_limit(text, dw - 24);
	draw_label(shortlabel, xx + 24, yy + (h/2), fa_left, fa_middle, c_text_secondary, a_text_secondary)
	
	microani_update(mouseon, mouseclick, active)
	
	if (string_width(shortlabel) < dw - 28)
		draw_help_circle(tip, xx + 24 + string_width(shortlabel) + 4, yy + (h/2) - 10, false)
	
	// Press
	if (pressed && mouse_left_released)
	{
		if (script != null)
			script_execute(script, !active)
		
		return true
	}
}
