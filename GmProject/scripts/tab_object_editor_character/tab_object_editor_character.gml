function tab_object_editor_character()
{
	var labeltext, list, capwid;
	switch (obj_edit.type)
	{
		case e_temp_type.CHARACTER:
		{
			labeltext = text_get("templateeditormodel")
			list = tab.char_list
			capwid = 0
			break
		}
		case e_temp_type.EQUIPMENT:
		{
			labeltext = text_get("templateeditorequipment")
			list = tab.equipment_list
			capwid = 0
			break
		}
		case e_temp_type.SPECIAL_BLOCK:
		{
			labeltext = text_get("templateeditorblock")
			list = tab.special_block_list
			capwid = 0
			break
		}
		case e_temp_type.MODEL_PART:
		{
			labeltext = text_get("templateeditormodel")
			list = tab.model_part_model_list
			capwid = text_caption_width("templateeditormodelpart")
			break
		}
	}
			
	// Model
	var statelen, statesh, menus, checkboxes;
	statelen = array_length(obj_edit.model_state)
	statesh = ((obj_edit.type = e_temp_type.MODEL_PART) ? 32 : 0)
	menus = 0
	checkboxes = 0
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.model_state[i + 1] != "true" && obj_edit.model_state[i + 1] != "false")
			menus++
		else
			checkboxes++
	}
			
	statesh += (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
	sortlist_draw(list, dx, dy, dw, dh - statesh, obj_edit.model_name, false)
	menu_filter = list.search_tbx.text
	menu_filter_normal = sortlist_column_get(list, obj_edit.model_name, 0)
			
	// Update states in case model was updated
	statelen = array_length(obj_edit.model_state)
	statesh = ((obj_edit.type = e_temp_type.MODEL_PART) ? 32 : 0)
	menus = 0
	checkboxes = 0
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.model_state[i + 1] != "true" && obj_edit.model_state[i + 1] != "false")
			menus++
		else
			checkboxes++
	}
			
	statesh += (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			
	// States
	var model = mc_assets.model_name_map[?obj_edit.model_name];
			
	draw_set_font(font_label)
	for (var i = 0; i < statelen; i += 2)
	{
		var state = obj_edit.model_state[i];
		capwid = max(capwid, string_width(minecraft_asset_get_name("modelstate", state)) + 8)
	}
			
	var dyy = (dy + dh - statesh) + 8;
			
	// Checkboxes
	dy = dyy
	tab_set_collumns(true, 2)
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.model_state[i + 1] != "true" && obj_edit.model_state[i + 1] != "false")
			continue
				
		var state = obj_edit.model_state[i];
		menu_model_current = model
		menu_model_state_current = model ? model.states_map[?state] : null
				
		tab_control(ui_small_height)
				
		if (draw_checkbox("modelstate" + state, dx, dy, obj_edit.model_state[i + 1] = "true", null))
		{
			menu_model_state = menu_model_state_current
					
			var script = (obj_edit.type = e_temp_type.MODEL_PART) ? action_lib_model_part_model_state : action_lib_model_state;
					
			if (obj_edit.model_state[i + 1] = "true")
				script_execute(script, "false")
			else
				script_execute(script, "true")
		}
				
		tab_next()
	}
			
	tab_set_collumns(false)
	dyy = dy
			
	// Menus
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.model_state[i + 1] = "true" || obj_edit.model_state[i + 1] = "false")
			continue
				
		var state = obj_edit.model_state[i];
		menu_model_current = model
		menu_model_state_current = model ? model.states_map[?state] : null
		draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, obj_edit.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", obj_edit.model_state[i + 1]), (obj_edit.type = e_temp_type.MODEL_PART) ? action_lib_model_part_model_state : action_lib_model_state, false, null, null, "", c_white, 1, capwid)
		dyy += 32
	}
	menu_model_current = null
	menu_filter = ""
	menu_filter_normal = ""
			
	// Model part
	if (obj_edit.type = e_temp_type.MODEL_PART)
		draw_button_menu("templateeditormodelpart", e_menu.LIST, dx, dyy, dw, 24, obj_edit.model_part_name, minecraft_asset_get_name("modelpart", obj_edit.model_part_name), action_lib_model_part_name, false, null, null, "", c_white, 1, capwid)
			
	if (content_mouseon)
		window_scroll_focus = string(list.scroll)
}