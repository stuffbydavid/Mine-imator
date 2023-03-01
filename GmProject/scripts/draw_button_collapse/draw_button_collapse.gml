/// draw_button_collapse(name, open, script, active, caption, tip)
/// @arg name
/// @arg open
/// @arg script
/// @arg active
/// @arg caption
/// @arg tip

function draw_button_collapse(name, open, script, active, caption, tip = "")
{
	// Mouse states
	draw_set_font(font_label)
	
	var xx, yy, wid, mouseon, mousepress, mouseclick;
	xx = dx - 8
	yy = dy + (tab_control_h / 2) - 10
	wid = string_width(text_get(caption)) + 26
	
	mouseon = app_mouse_box(xx, dy, wid, 24) && content_mouseon && active
	mousepress = mouseon && mouse_left
	mouseclick = mouseon && mouse_left_released
	
	if (xx + wid < content_x || xx > content_x + content_width || dy + 24 < content_y || dy > content_y + content_height)
		return 0
	
	// Button
	draw_button_icon(name + "collapse", xx, yy, 20, 20, open && active, null, null, !active, "", spr_chevron_ani)
	microani_update(mouseon, mousepress, open && active)
	
	// Tip
	//if (mouseon && active)
	//	tip_set(text_get((open ? "tooltiphideoptions" : "tooltipshowoptions")), xx, yy, 16, 16, false)
	
	// Cursor
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	dx += 16
	dw -= 16
	tab_collapse = true
	collapse_ani = test_reduced_motion(open, microani_arr[e_microani.ACTIVE])
	
	// Switch/label
	if (script)
		draw_switch(caption, dx, dy, active, script, tip)
	else
	{
		draw_label(text_get(caption), dx, dy + tab_control_h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		draw_help_circle(tip, dx + string_width(text_get(caption)) + 4, dy + 2, false)
	}
	
	// Interact with collapse map?
	if (mouseclick && ds_map_exists(collapse_map, name))
		action_collapse(name, !collapse_map[?name])
	
	return mouseclick
}
