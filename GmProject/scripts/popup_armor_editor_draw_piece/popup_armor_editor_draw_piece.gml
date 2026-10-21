function popup_armor_editor_draw_piece(piece, pieceid)
{
	if (settings_menu_name != "")
		settings_menu_busy_prev = "popup/" + popup_current.name
	
	if (context_menu_name != "")
		context_menu_busy_prev = "popup/" + popup_current.name
	
	if (ds_list_size(menu_list) > 0)
		menu_list[|0].menu_busy_prev = "popup/" + popup_current.name
	
	var piecetype = "";
	
	popup_armor_editor.piece_current = pieceid
	
	tab_control(24)
	piecetype = popup_armor_editor_draw_piece_type(piece, pieceid)
	tab_next()
	
	popup_armor_editor.piece_data_id = 2
	
	tab_control(24)
	content_text = text_get("armor_editor/pattern/" + popup_current.armor_edit.armor_array[pieceid + 2])
	draw_button_menu("armor_editor/pattern_" + piece, e_menu.LIST, dx, dy, dw, 24, popup_current.armor_edit.armor_array[pieceid + 2], content_text, action_armor_editor, piecetype = "none", null, null, "", c_white, 1, content_capwid)
	tab_next()
	
	popup_armor_editor.piece_data_id = 3
	
	tab_control(24)
	content_text = text_get("armor_editor/material/" + popup_current.armor_edit.armor_array[pieceid + 3])
	draw_button_menu("armor_editor/material_" + piece, e_menu.LIST, dx, dy, dw, 24, popup_current.armor_edit.armor_array[pieceid + 3], content_text, action_armor_editor, (piecetype = "none" || popup_current.armor_edit.armor_array[pieceid + 2] = "none"), null, null, "", c_white, 1, content_capwid)
	tab_next()
}
