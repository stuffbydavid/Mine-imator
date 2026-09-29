function bench_draw_settings_block()
{
	bench_create_name = "benchbuild"
	bench_create_icon = icons.BLOCK
	bench_create_button = e_bench_button.START_BUILDING
	
	bench_edit_hidden = false
	bench_edit_name = "benchcreate"
	bench_edit_icon = icons.ASSET_ADD
	bench_edit_button = e_bench_button.CREATE

	draw_set_font(font_label)

	content_capwid = text_caption_width("benchblocktex", "benchblocktexmaterial", "benchblocktexnormal")

	tab_control(bench_list_height(bench_settings.block_list))
	sortlist_draw(bench_settings.block_list, dx, dy, dw, tab_control_h, bench_settings.block_name, false, text_get("benchblock"))
	tab_next()
	
	menu_filter = bench_settings.block_list.search_tbx.text
	menu_filter_normal = sortlist_column_get(bench_settings.block_list, bench_settings.block_name, 0)

	// States
	var block, statelen;
	block = mc_assets.block_name_map[?bench_settings.block_name]
	statelen = array_length(bench_settings.block_state)

	for (var i = 0; i < statelen; i += 2)
	{
		var state = bench_settings.block_state[i];
		content_capwid = max(content_capwid, text_caption_width(minecraft_asset_get_name("blockstate", state)))
	}

	// Checkboxes
	tab_set_columns(true, 2)

	for (var i = 0; i < statelen; i += 2)
	{
		if (bench_settings.block_state[i + 1] != "true" && bench_settings.block_state[i + 1] != "false")
			continue

		var state = bench_settings.block_state[i];
		menu_block_current = block
		menu_block_state_current = block.states_map[?state]

		tab_control(ui_small_height)

		if (draw_checkbox("blockstate" + state, dx, dy, bench_settings.block_state[i + 1] = "true", null))
		{
			menu_block_state = menu_block_state_current

			if (bench_settings.block_state[i + 1] = "true")
				action_bench_block_state("false")
			else
				action_bench_block_state("true")
		}

		tab_next()
	}

	tab_set_columns(false)

	// Menus
	for (var i = 0; i < statelen; i += 2)
	{
		if (bench_settings.block_state[i + 1] = "true" || bench_settings.block_state[i + 1] = "false")
			continue

		var state = bench_settings.block_state[i];
		menu_block_current = block
		menu_block_state_current = block.states_map[?state]
		
		draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", bench_settings.block_state[i + 1]), action_bench_block_state, false, null, null, "", null, null, content_capwid)
		dy += 32
	}

	menu_block_current = null
	menu_filter = ""
	menu_filter_normal = ""

	// Texture
	draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex, res_eval(bench_settings.block_tex).display_name, action_bench_block_tex, false, res_eval(bench_settings.block_tex).block_preview_texture, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Material texture
		draw_button_menu("benchblocktexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex_material, res_eval(bench_settings.block_tex_material).display_name, action_bench_block_tex_material, false, res_eval(bench_settings.block_tex_material).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Normal texture
		draw_button_menu("benchblocktexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.block_tex_normal, res_eval(bench_settings.block_tex_normal).display_name, action_bench_block_tex_normal, false, res_eval(bench_settings.block_tex_normal).block_preview_texture, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}
	dy += 4

	window_scroll_focus = string(bench_settings.block_list.scroll)
}
