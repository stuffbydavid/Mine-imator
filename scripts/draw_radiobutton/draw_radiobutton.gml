/// draw_radiobutton(name, x, y, value, active, script)
/// @arg name
/// @arg x
/// @arg y
/// @arg value
/// @arg active
/// @arg script

function draw_radiobutton(name, xx, yy, value, active, script)
{
	var text, w, h, mouseon, pressed;
	text = text_get(argument0)
	
	draw_set_font(font_label)
	
	w = 28 + string_width(name)
	h = 28
	
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
	buttony = (yy + (28/2))
	
	// Draw button
	var buttoncolor = merge_color(c_text_secondary, c_accent, mcroani_arr[e_mcroani.PRESS]);
	buttoncolor = merge_color(buttoncolor, c_accent, mcroani_arr[e_mcroani.ACTIVE])
	
	var buttonalpha = lerp(a_text_secondary, 1, mcroani_arr[e_mcroani.PRESS]);
	buttonalpha = lerp(buttonalpha, 1, mcroani_arr[e_mcroani.ACTIVE])
	
	// Off
	draw_image(spr_radiobutton, 0, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * (1 - mcroani_arr[e_mcroani.ACTIVE]) * (1 - mcroani_arr[e_mcroani.HOVER]))
	
	// Off (hover)
	draw_image(spr_radiobutton, 1, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * (1 - mcroani_arr[e_mcroani.ACTIVE]) * (mcroani_arr[e_mcroani.HOVER]))
	
	// On
	draw_image(spr_radiobutton, 2, buttonx, buttony, 1, 1, buttoncolor, buttonalpha * mcroani_arr[e_mcroani.ACTIVE] * (1 - mcroani_arr[e_mcroani.RADIO_HOVER]))
	
	// Draw hover outline
	draw_image(spr_radiobutton_hover, 0, buttonx, buttony, 1, 1, c_accent_hover, a_accent_hover * mcroani_arr[e_mcroani.HOVER])
	
	// Label
	draw_label(text, xx + 28, yy + 14, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_value)
	
	microani_update(mouseon, mouseclick, active)
	
	// Press
	if (pressed && mouse_left_released)
	{
		if (script != null)
			script_execute(script, value)
		
		return true
	}
}
