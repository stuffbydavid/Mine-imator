/// draw_subheader(category, x, y, width, height)
/// @arg category
/// @arg x
/// @arg y
/// @arg width
/// @arg height

function draw_subheader(cat, xx, yy, w, h)
{
	var mouseon, cap;
	
	draw_set_font(font_subheading)
	cap = string_limit(text_get(cat.name), dw - (h + 4))
	
	mouseon = app_mouse_box(xx, yy, w, h) && content_mouseon
	
	microani_set(cat.name + "close", null, false, false, cat.show, false)
	
	var color, alpha, focus, frame;
	focus = max(microani_arr[e_microani.ACTIVE], microani_arr[e_microani.PRESS])
	
	color = merge_color(c_text_tertiary, c_text_secondary, microani_arr[e_microani.HOVER])
	color = merge_color(color, c_accent, focus)
	color = merge_color(color, c_accent_hover, microani_arr[e_microani.HOVER] * microani_arr[e_microani.ACTIVE])
	color = merge_color(color, c_accent_pressed, microani_arr[e_microani.PRESS] * microani_arr[e_microani.ACTIVE])
	
	alpha = lerp(a_text_tertiary, a_text_secondary, microani_arr[e_microani.HOVER])
	alpha = lerp(alpha, a_accent, focus)
	
	frame = floor((sprite_get_number(spr_chevron_ani) - 1) * microani_arr[e_microani.ACTIVE])
	
	draw_image(spr_chevron_ani, frame, xx + 8, yy + h/2, 1, 1, color, alpha)
	draw_label(cap, xx + 20, yy + (h/2) - 1, fa_left, fa_middle, color, alpha)
	
	microani_update(mouseon, mouseon && mouse_left, cat.show)
	
	if (mouseon)
	{
		mouse_cursor = cr_handpoint
		
		if (mouse_left_released)
			cat.show = !cat.show
	}
}
