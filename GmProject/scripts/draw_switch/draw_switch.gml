/// draw_switch(name, x, y, active, script, [tip, [disabled]])
/// @arg name
/// @arg x
/// @arg y
/// @arg active
/// @arg script
/// @arg [tip
/// @arg [disabled]]

function draw_switch(name, xx, yy, active, script, tip = "", disabled = false)
{
	var text, switchx, switchy, w, h, pressed, thumbgoal;
	
	text = text_get(name)
	
	w = dw
	h = ui_small_height
	switchx = (xx + dw - 22)
	switchy = (yy + (h/2) - 7)
	
	if (xx + w < content_x || xx > content_x + content_width || yy + h < content_y || yy > content_y + content_height)
		return 0
	
	// Mouse
	var mouseon, mouseclick;
	mouseon = app_mouse_box(switchx, switchy, h, 16) && content_mouseon && !disabled
	mouseclick = mouseon && mouse_left
	
	pressed = false
	
	if (mouseon)
	{
		if (mouse_left || mouse_left_released)
			pressed = true
		
		mouse_cursor = cr_handpoint
	}
	
	if (pressed)
		thumbgoal = 0.5
	else if (active)
		thumbgoal = 1
	else
		thumbgoal = 0
	
	// Set micro animation before drawing
	microani_set(name, script, mouseon, mouseclick, active, disabled, 1, 0, thumbgoal)
	
	// Draw background
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
	
	draw_box(switchx, switchy, 20, 14, false, color, alpha)
	
	// Draw button
	var buttonx, buttony;
	buttonx = switchx + 2 + floor(8 * microani_arr[e_microani.GOAL_EASE])
	buttony = switchy + 2
	draw_box(buttonx, buttony, 8, 10, false, c_button_text, 1)
	draw_box_bevel(buttonx, buttony, 8, 10, 1, setting_theme.name = "light")
	
	// Draw hover outline
	draw_box_hover(switchx, switchy, 20, 14, microani_arr[e_microani.PRESS])
	
	// Label
	draw_set_font(font_label)
	draw_label(string_limit(text, w - 32), xx, yy + (h/2), fa_left, fa_middle, lerp(c_text_secondary, c_text_tertiary, microani_arr[e_microani.DISABLED]), lerp(a_text_secondary, a_text_tertiary, microani_arr[e_microani.DISABLED]))
	
	microani_update(mouseon, mouseclick, active, disabled, 0, thumbgoal)
	
	draw_help_circle(tip, xx + string_width(text) + 4, yy + (h/2) - 10, disabled)
	
	// Press
	if (pressed && mouse_left_released)
	{
		if (script != null)
			script_execute(script, !active)
		
		return true
	}
}
