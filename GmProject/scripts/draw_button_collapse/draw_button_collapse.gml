/// @arg name
/// @arg open
/// @arg script
/// @arg active
/// @arg caption
/// @arg [tip]
/// @arg [expandonenable]

function draw_button_collapse(name, open, script, active, caption, tip = "", expandonenable = true)
{
	// Mouse states
	draw_set_font(font_label)
	
	var xx, yy, wid, mouseon, mousepress, mouseclick, switchclick, labelclick, hascollapse, labelwid;
	xx = dx - 8
	yy = dy + (tab_control_h / 2) - 10
	wid = script ? string_width(text_get(caption)) + 26 : dw + 8
	switchclick = false
	hascollapse = ds_map_exists(collapse_map, name)
	labelclick = false
	labelwid = string_width(string_limit(text_get(caption), dw - 48))
	
	mouseon = app_mouse_box(xx, dy, wid, 24) && content_mouseon && active
	mousepress = mouseon && mouse_left
	mouseclick = mouseon && mouse_left_released && (!script || app_mouse_box(xx, dy, 20, 24))
	
	if (xx + wid < content_x || xx > content_x + content_width || dy + 24 < content_y || dy > content_y + content_height)
		return 0
	
	// Button
	draw_button_icon(name + "collapse", xx, yy, 20, 20, open && active, null, null, !active, "", spr_chevron_ani)
	microani_update(mouseon, mousepress, open && active, !active)
	
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
	{
		labelclick = hascollapse && mouse_left_released && content_mouseon && app_mouse_box(dx - 4, dy - 4, labelwid + 8, ui_small_height + 8) && !app_mouse_box(dx + dw - 22, dy + (ui_small_height / 2) - 7, 20, 14)
		switchclick = draw_switch(caption, dx, dy, active, script, tip, false, hascollapse)
	}
	else
	{
		draw_label(text_get(caption), dx, dy + tab_control_h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
		draw_help_circle(tip, dx + string_width(text_get(caption)) + 4, dy + 2, false)
	}
	
	// Expand on click
	if (expandonenable && switchclick)
	{
		if (labelclick && active)
			action_collapse(name, !collapse_map[?name])
		else if (!active)
			action_collapse(name, true)
	}
	
	// Interact with collapse map?
	if (mouseclick && hascollapse)
		action_collapse(name, !collapse_map[?name])
	
	return mouseclick
}
