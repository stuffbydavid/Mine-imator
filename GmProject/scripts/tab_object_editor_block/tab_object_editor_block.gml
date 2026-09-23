function tab_object_editor_block()
{
	// Block
	var statelen, statesh, menus, checkboxes, capwid, list, selected;
	list = (tab = build_tool) ? tab.build_list : tab.block_list
	selected = (tab = build_tool) ? tab.build_selected : obj_edit.block_name
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
	var block;
	block = mc_assets.block_name_map[?obj_edit.block_name]
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
	capwid = 0
			
	draw_set_font(font_label)
	for (var i = 0; i < statelen; i += 2)
	{
		var state = obj_edit.block_state[i];
		capwid = max(capwid, string_width(minecraft_asset_get_name("blockstate", state)) + 8)
	}
			
	var dyy = (dy + dh - statesh) + 8;
			
	// Checkboxes
	dy = dyy
	tab_set_collumns(true, 2)
			
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] != "true" && obj_edit.block_state[i + 1] != "false")
			continue
				
		var state = obj_edit.block_state[i];
		menu_block_current = block
		menu_block_state_current = block ? block.states_map[?state] : null
				
		tab_control(ui_small_height)
				
		if (draw_checkbox("blockstate" + state, dx, dy, obj_edit.block_state[i + 1] = "true", null))
		{
			menu_block_state = menu_block_state_current
					
			if (obj_edit.block_state[i + 1] = "true")
				script_execute((tab = build_tool) ? action_bench_block_state : action_lib_block_state, "false")
			else
				script_execute((tab = build_tool) ? action_bench_block_state : action_lib_block_state, "true")
		}
				
		tab_next()
	}
			
	tab_set_collumns(false)
	dyy = dy
			
	// Menus
	for (var i = 0; i < statelen; i += 2)
	{
		if (obj_edit.block_state[i + 1] = "true" || obj_edit.block_state[i + 1] = "false")
			continue
				
		var state = obj_edit.block_state[i];
		menu_block_current = block
		menu_block_state_current = block ? block.states_map[?state] : null
		draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, obj_edit.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", obj_edit.block_state[i + 1]), (tab = build_tool) ? action_bench_block_state : action_lib_block_state, false, null, null, "", c_white, 1, capwid)
		dyy += 32
	}
	menu_block_current = null
	menu_filter = ""
	menu_filter_normal = ""
			
	if (content_mouseon)
		window_scroll_focus = string(list.scroll)
}
