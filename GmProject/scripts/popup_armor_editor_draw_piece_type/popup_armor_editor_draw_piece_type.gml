function popup_armor_editor_draw_piece_type(piece, pieceid, capwid)
{
	var statelen, w, type;
	statelen = array_length(popup.armor_edit.model_state)
	w = dw
	type = ""
	
	for (var i = 0; i < statelen; i += 2)
	{
		var state, model;
		state = popup.armor_edit.model_state[i]
		model = mc_assets.model_name_map[?"armor"]
		
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
			draw_button_menu(state, e_menu.LIST, dx, dy, w, 24, type, minecraft_asset_get_name("modelstatevalue", type), (popup.armor_edit.type = e_temp_type.MODEL_PART) ? action_lib_model_part_model_state : action_lib_model_state, false, null, null, "", c_white, 1, capwid)
	}
	
	menu_model_current = null
	
	return type
}
