function tab_build_tool()
{
	if (!place_build)
	{
		tab_close(tab)
		return 0
	}

	// First-person mode help
	var optiony = dy;
	if (build_first_person)
	{
		dy += 10
		var fpkey = keybinds[e_keybind.BUILD_FIRST_PERSON].keybind;
		if (fpkey[e_keybind_key.CHAR] != vk_nokey)
			draw_tooltip_label("build_tool/first_person_tip", icons.INFO, e_toast.INFO, fa_left, text_get("build_tool/first_person_tip", text_control_name(fpkey)))
		else
			draw_tooltip_label("build_tool/first_person_tip_escape", icons.INFO, e_toast.INFO)

		dy = optiony + 44
	}

	// Structure
	var structurevalue, structuretext, structurecapwidth;
	structurevalue = build_structure
	if (structurevalue != null && !instance_exists(structurevalue))
		structurevalue = null

	structuretext = text_get("build_tool/create_new")
	if (structurevalue != null)
		structuretext = structurevalue.display_name

	draw_set_font(font_label)
	structurecapwidth = string_width(text_get("build_tool/structure")) + 8

	draw_button_menu("build_tool/structure", e_menu.LIST, dx, dy, dw, 24, structurevalue, structuretext, action_build_structure_select, false, null, null, "", null, null, structurecapwidth)
	dy += 32

	// Block/special block picker
	var picker, pickerh, settingsy, res, states, asset, script, selected;
	res = project_pack_res
	if (structurevalue != null)
		res = structurevalue.render_res_diffuse

	picker = tab.build_picker
	selected = tab.build_selected
	if (build_settings.type = e_temp_type.SPECIAL_BLOCK)
	{
		states = build_settings.model_state
		asset = mc_assets.model_name_map[?build_settings.model_name]
		script = action_bench_model_state
	}
	else
	{
		states = build_settings.block_state
		asset = mc_assets.block_name_map[?build_settings.block_name]
		script = action_bench_block_state
	}
	
	if (selected != null)
		state_settings_load(asset, true, states, dw, picker.grid_view)
	else
		state_settings_height = 0
	settingsy = max(dy + 8, optiony + dh - 20 - state_settings_height)
	
	pickerh = settingsy - dy - 8
	draw_asset_picker(picker, res, selected, states, dx, dy, dw, pickerh, text_get("bench/block"))
	
	dy = settingsy
	
	if (content_mouseon)
		window_scroll_focus = string(picker.scroll)

	// State settings
	content_capwid = 0
	if (selected != null)
		dy += draw_state_settings(picker.search_tbx.text, script, dx, dy, dw, res, tab.state_picker)
}
