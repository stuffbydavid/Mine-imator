/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg index

function draw_button_accent(xx, yy, wid, hei, index)
{
	wid = floor(wid)
	hei = floor(hei)
	
	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height)
		return 0
	
	var mouseon, mouseclick, accent;
	mouseon = app_mouse_box(xx, yy, wid, hei) && content_mouseon
	mouseclick = mouseon && mouse_left
	
	if (index < 9)
		accent = setting_theme.accent_list[index]
	else
		accent = null
	
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	microani_set("accent/list_item" + string(index), null, mouseon, mouseclick, setting_accent = index, 0.5)
	microani_update(mouseon, mouseclick, setting_accent = index, 0.5)
	
	if (accent != null)
	{
		draw_box(xx, yy, wid, hei, false, accent, 1)
		draw_image(spr_icons, icons.TICK, xx + wid/2, yy + hei/2, 1, 1, c_level_middle, microani_arr[e_microani.ACTIVE])
	}
	else
	{
		draw_outline(xx + 1, yy + 1, wid - 2, hei - 2, 1, c_border, a_border)
		draw_box(xx, yy, wid, hei, false, setting_accent_custom, microani_arr[e_microani.ACTIVE])
		draw_image(spr_icons, icons.PICKER, xx + wid/2, yy + hei/2, 1, 1, merge_color(c_text_secondary, c_level_middle, microani_arr[e_microani.ACTIVE]), lerp(a_text_secondary, 1, microani_arr[e_microani.ACTIVE]))
		
		tip_set(text_get("tooltip/custom_accent_color"), xx, yy, wid, hei)
	}
	
	// Hover/press animation
	var buttoncolor, buttonalpha;
	buttoncolor = merge_color(c_white, c_black, microani_arr[e_microani.PRESS])
	buttonalpha = lerp(0, .17, microani_arr[e_microani.HOVER] * (1 - microani_arr[e_microani.PRESS]))
	buttonalpha = lerp(buttonalpha, .20, microani_arr[e_microani.PRESS])
	
	draw_box(xx, yy, wid, hei, false, buttoncolor, buttonalpha)
	draw_box_hover(xx, yy, wid, hei, microani_arr[e_microani.HOVER])
	
	if (mouseon && mouse_left_released)
	{
		setting_accent = index
		update_interface_timeout = current_time + 10000
		update_interface_wait = true
		
		return true
	}
}
