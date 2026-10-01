function tab_object_editor_block()
{
	// Block
	var list, selected, script, statelen, statesh, menus, checkboxes;
	if (tab = build_tool)
	{
		list = tab.build_list
		selected = tab.build_selected
		script = action_bench_block_state
	}
	else
	{
		list = tab.block_list
		selected = obj_edit.block_name
		script = action_lib_block_state
	}
	
	statelen = array_length(obj_edit.block_state)
	menus = 0
	checkboxes = 0
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] != "true" && obj_edit.block_state[i + 1] != "false")
			menus++
		else
			checkboxes++
	}
			
	statesh = (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			
	sortlist_draw(list, dx, dy, dw, dh - statesh, selected, false)
	menu_filter = list.search_tbx.text
	menu_filter_normal = (selected = null) ? "" : sortlist_column_get(list, selected, 0)
	
	// States
	var block = mc_assets.block_name_map[?obj_edit.block_name];
	statelen = array_length(obj_edit.block_state)
	menus = 0
	checkboxes = 0
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] != "true" && obj_edit.block_state[i + 1] != "false")
			menus++
		else
			checkboxes++
	}
			
	statesh = (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
	content_capwid = 0
			
	draw_set_font(font_label)
	for (var i = 0; i < statelen; i += 2)
	{
		var state = obj_edit.block_state[i];
		content_capwid = max(content_capwid, string_width(minecraft_asset_get_name("block/state", state)) + 8)
	}
			
	var dyy = (dy + dh - statesh) + 8;
			
	// Checkboxes
	dy = dyy
	tab_set_columns(true, 2)
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] != "true" && obj_edit.block_state[i + 1] != "false")
			continue
				
		var state = obj_edit.block_state[i];
		menu_block_current = block
		menu_block_state_current = block ? block.states_map[?state] : null
				
		tab_control(ui_small_height)
				
		if (draw_checkbox("block/state/" + state, dx, dy, obj_edit.block_state[i + 1] = "true", null))
		{
			menu_block_state = menu_block_state_current
					
			if (obj_edit.block_state[i + 1] = "true")
				script_execute(script, "false")
			else
				script_execute(script, "true")
		}
				
		tab_next()
	}
			
	tab_set_columns(false)
	dyy = dy
			
	// Menus
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] = "true" || obj_edit.block_state[i + 1] = "false")
			continue
				
		var state = obj_edit.block_state[i];
		menu_block_current = block
		menu_block_state_current = block ? block.states_map[?state] : null
		draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, obj_edit.block_state[i + 1], minecraft_asset_get_name("block/state/value", obj_edit.block_state[i + 1]), script, false, null, null, "", c_white, 1, content_capwid)
		dyy += 32
	}
	
	menu_block_current = null
	menu_filter = ""
	menu_filter_normal = ""
			
	if (content_mouseon)
		window_scroll_focus = string(list.scroll)
}
