function tab_build_hotbars()
{
	tab_control(24)
	draw_label(text_get("build_hotbars") + ":", dx, dy + 12, fa_left, fa_middle, c_text_secondary, a_text_secondary, font_label)
	tab_next()

	// Hotbar list
	tab_control_sortlist(tab.list)
	sortlist_draw(tab.list, dx, dy, dw, tab_control_h, build_hotbar_current)
	tab_next()

	// Hotbar tools
	tab_control(24)
	
	if (draw_button_icon("hotbar/create", dx, dy, 24, 24, false, icons.HOTBAR_ADD, null, false, "tooltip/hotbar/create_hotbar"))
		action_build_hotbar_create()
	
	if (draw_button_icon("hotbar/duplicate", dx + 28, dy, 24, 24, false, icons.DUPLICATE, null, false, "tooltip/hotbar/duplicate_hotbar"))
		action_build_hotbar_duplicate()
	
	if (draw_button_icon("hotbar/remove", dx + 56, dy, 24, 24, false, icons.DELETE, null, ds_list_size(tab.list.list) <= 1, "tooltip/hotbar/remove_hotbar"))
		action_build_hotbar_remove()
	
	tab_next()

	// Selected hotbar name
	tab_control(24)
	tab.tbx_name.text = build_hotbar_current.name
	draw_textfield("build_hotbars/name", dx, dy, dw, 24, tab.tbx_name, action_build_hotbar_name, build_hotbar_current.name, "left")
	tab_next()
}
