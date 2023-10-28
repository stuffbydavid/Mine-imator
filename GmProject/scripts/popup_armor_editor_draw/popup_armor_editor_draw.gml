/// popup_armor_editor_draw()

function popup_armor_editor_draw_piece_type(piece, pieceid, capwid)
{
	var statelen = array_length(popup.armor_edit.model_state);
	var w = dw;
	var type = "";
	
	for (var i = 0; i < statelen; i += 2)
	{
		var state = popup.armor_edit.model_state[i];
		var model = mc_assets.model_name_map[?"armor"];
		
		if (state != piece)
			continue
		
		menu_model_current = model
		menu_model_state_current = model.states_map[?state]
		type = popup.armor_edit.model_state[i + 1]
		
		// Room for color button
		if (type = "leather")
		{
			w -= (28 + 8)
			
			if (draw_button_color("armoreditordye" + piece, dx + dw - 24, dy, 24, popup.armor_edit.armor_array[pieceid + 1], minecraft_get_color("other:leather"), false, action_armor_editor))
			{
				menu_armor_piece = pieceid
				menu_armor_piece_data = 1
			}
		}
		
		if (popup.armor_edit = bench_settings)
			draw_button_menu(state, e_menu.LIST, dx, dy, w, 24, type, minecraft_asset_get_name("modelstatevalue", type), action_bench_model_state, false, null, null, "", c_white, 1, capwid)
		else
			draw_button_menu(state, e_menu.LIST, dx, dy, w, 24, type, minecraft_asset_get_name("modelstatevalue", type), (popup.armor_edit.type = e_temp_type.BODYPART) ? action_lib_bodypart_model_state : action_lib_model_state, false, null, null, "", c_white, 1, capwid)
	}
	menu_model_current = null
	
	return type
}

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

function popup_armor_editor_draw()
{
	popup.preview.select = popup.armor_edit
	popup.preview.last_select = popup.armor_edit
	popup.preview.update = true
	preview_draw(popup.preview, dx, dy, 200, dh - (dy - content_y))
	
	// Settings
	dx += 216
	dw = 310
	
	var capwid = 128;
	
	popup_armor_editor_draw_piece("helmet", 0, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("chestplate", 4, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("leggings", 8, capwid)
	
	draw_divide(dx, dy, dw)
	dy += 8
	
	popup_armor_editor_draw_piece("boots", 12, capwid)
}
