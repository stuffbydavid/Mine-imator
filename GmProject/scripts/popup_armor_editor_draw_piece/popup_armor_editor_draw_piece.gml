function popup_armor_editor_draw_piece(piece, pieceid, capwid)
{
	if (settings_menu_name != "")
		settings_menu_busy_prev = "popup" + popup.name
	
	if (context_menu_name != "")
		context_menu_busy_prev = "popup" + popup.name
	
	if (ds_list_size(menu_list) > 0)
		menu_list[|0].menu_busy_prev = "popup" + popup.name
	
	var piecetype = "";
	
	popup_armor_editor.piece_current = pieceid
	
	tab_control(24)
	piecetype = popup_armor_editor_draw_piece_type(piece, pieceid, capwid)
	tab_next()
	
	popup_armor_editor.piece_data_id = 2
	
	tab_control(24)
	draw_button_menu("armoreditorpattern" + piece, e_menu.LIST, dx, dy, dw, 24, popup.armor_edit.armor_array[pieceid + 2], text_get("armoreditorpattern" + popup.armor_edit.armor_array[pieceid + 2]), action_armor_editor, piecetype = "none", null, null, "", c_white, 1, capwid)
	tab_next()
	
	popup_armor_editor.piece_data_id = 3
	
	tab_control(24)
	draw_button_menu("armoreditormaterial" + piece, e_menu.LIST, dx, dy, dw, 24, popup.armor_edit.armor_array[pieceid + 3], text_get("armoreditormaterial" + popup.armor_edit.armor_array[pieceid + 3]), action_armor_editor, (piecetype = "none" || popup.armor_edit.armor_array[pieceid + 2] = "none"), null, null, "", c_white, 1, capwid)
	tab_next()
}
