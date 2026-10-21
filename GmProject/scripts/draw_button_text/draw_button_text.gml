/// @arg text
/// @arg x
/// @arg y
/// @arg script
/// @arg value
/// @arg [tip]
/// @arg [font]

function draw_button_text(text, xx, yy, script, value, tip = "", font = null)
{
	if (font = null)
		font = font_value
	
	draw_set_font(font)
	
	var wid, hei, mouseon;
	wid = string_width(text)
	hei = string_height(text)
	mouseon = app_mouse_box(xx, yy - hei, wid, hei)
	
	microani_set(text, script, mouseon, mouseon && mouse_left, false)
	
	var color, alpha;
	color = merge_color(c_accent, c_accent_hover, microani_arr[e_microani.HOVER])
	alpha = lerp(a_accent, a_accent_hover, microani_arr[e_microani.HOVER])
	color = merge_color(color, c_accent_pressed, microani_arr[e_microani.PRESS])
	alpha = lerp(alpha, a_accent_pressed, microani_arr[e_microani.PRESS])
	
	draw_label(text, xx, yy, fa_left, fa_bottom, color, alpha)
	
	var grow = 3 - (3 * (microani_arr[e_microani.HOVER] * (1 - microani_arr[e_microani.PRESS])));
	draw_line_ext(xx + grow, yy, xx + wid - (grow * 2), yy, color, alpha * microani_arr[e_microani.HOVER])
	
	if (mouseon)
	{
		mouse_cursor = cr_handpoint
		
		if (tip != "")
			tip_set(tip, xx, yy - hei, wid, hei)
		
		if (mouse_left_released && script != null)
		{
			script_execute(script, value)
			app_mouse_clear()
		}
	}
	
	microani_update(mouseon, mouseon && mouse_left, false)
}
