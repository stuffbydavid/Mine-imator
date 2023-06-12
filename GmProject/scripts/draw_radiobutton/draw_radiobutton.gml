/// draw_radiobutton(name, x, y, value, active, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg active
/// @arg script

function draw_radiobutton(name, xx, yy, value, active, script)
{
	var text, w, h, pressed;
	text = text_get(argument0)
	
	draw_set_font(font_label)
	
	w = ui_small_height + string_width(name)
	h = ui_small_height
	
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
	
	var buttonx, buttony;
	buttonx = xx + 10
	buttony = (yy + (ui_small_height/2))
	
	// Draw button
	var buttoncolor = merge_color(c_text_secondary, c_accent, microani_arr[e_microani.PRESS]);
	buttoncolor = merge_color(buttoncolor, c_accent, microani_arr[e_microani.ACTIVE])
	
	var buttonalpha = lerp(a_text_secondary, 1, microani_arr[e_microani.PRESS]);
	buttonalpha = lerp(buttonalpha, 1, microani_arr[e_microani.ACTIVE])
	
	// Off
	draw_image(spr_radiobutton, 0, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * (1 - microani_arr[e_microani.ACTIVE]) * (1 - microani_arr[e_microani.HOVER]))
	
	// Off (hover)
	draw_image(spr_radiobutton, 1, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * (1 - microani_arr[e_microani.ACTIVE]) * (microani_arr[e_microani.HOVER]))
	
	// On
	draw_image(spr_radiobutton, 2, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * microani_arr[e_microani.ACTIVE] * (1 - microani_arr[e_microani.RADIO_HOVER]))
	
	// Draw hover outline
	draw_image(spr_radiobutton_hover, 0, buttonx, buttony, 1, 1, c_accent_hover, a_accent_hover * microani_arr[e_microani.HOVER])
	
	// Label
	draw_label(text, xx + 28, yy + h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_value)
	
	microani_update(mouseon, mouseclick, active)
	
	// Press
	if (pressed && mouse_left_released)
	{
		if (script != null)
			script_execute(script, value)
		
		return true
	}
}
