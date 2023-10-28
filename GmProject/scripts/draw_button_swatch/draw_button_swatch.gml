/// draw_button_swatch(x, y, wid, hei, name, color)
/// @arg x
/// @arg y
/// @arg wid
/// @arg hei
/// @arg name
/// @arg color

function draw_button_swatch(xx, yy, wid, hei, name, color)
{
	var mouseon, mouseclick;
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
		return 0
	
	mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	mouseclick = mouseon && mouse_left
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set(name, null, mouseon, mouseclick, false)
	microani_update(mouseon, mouseclick, false)
	
	tip_set(text_get(name), xx, yy, wid, hei)
	
	draw_box(xx, yy, wid, hei, false, color, 1)
	draw_outline(xx, yy, wid, hei, 1, c_black, .1, true)
	
	// Hover/press animation
	var buttoncolor, buttonalpha;
	buttoncolor = merge_color(c_white, c_black, microani_arr[e_microani.PRESS])
	buttonalpha = lerp(0, .17, microani_arr[e_microani.HOVER] * (1 - microani_arr[e_microani.PRESS]))
	buttonalpha = lerp(buttonalpha, .20, microani_arr[e_microani.PRESS])
	
	draw_box(xx, yy, wid, wid, false, buttoncolor, buttonalpha)
	draw_box_hover(xx, yy, wid, hei, microani_arr[e_microani.HOVER])
	
	if (mouseon && mouse_left_released)
		return true
}
