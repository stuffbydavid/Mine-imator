/// draw_button_collapse(name, open, script, active, caption)
/// @arg name
/// @arg open
/// @arg script
/// @arg active
/// @arg caption

function draw_button_collapse(name, open, script, active, caption)
{
	// Mouse states
	draw_set_font(font_label)
	
	var xx, yy, wid, mouseon, mousepress, mouseclick;
	xx = dx - 8
	yy = dy + (tab_control_h / 2) - 8
	wid = string_width(text_get(caption)) + 21
	
	mouseon = app_mouse_box(xx, yy, wid, 16) && content_mouseon && active
	mousepress = mouseon && mouse_left
	mouseclick = mouseon && mouse_left_released
	
	// Button
	draw_button_icon(name + "collapse", xx, yy, 16, 16, open && active, null, null, !active, "", spr_chevron_ani)
	microani_update(mouseon, mousepress, open && active)
	
	// Tip
	if (mouseon && active)
		tip_set(text_get((open ? "tooltiphideoptions" : "tooltipshowoptions")), xx, yy, 16, 16, false)
	
	// Cursor
	if (mouseon)
		mouse_cursor = cr_handpoint
	
	dx += 12
	dw -= 12
	tab_collapse = true
	collapse_ani = mcroani_arr[e_mcroani.ACTIVE]
	
	// Switch/label
	if (script)
		draw_switch(caption, dx, dy, active, script)
	else
		draw_label(text_get(caption), dx, dy + tab_control_h/2, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	
	// Interact with collapse map?
	if (mouseclick && ds_map_exists(collapse_map, name))
		action_collapse(name, !collapse_map[?name])
	
	return mouseclick
}
