function bench_draw_settings_character()
{
	var labeltext, picker, texcap, texmatcap, texnormcap;
	
	switch (bench_tab)
	{
		case e_bench_tab.CHARACTER:
		{
			labeltext = text_get("bench/model")
			picker = bench_settings.char_picker
			texcap = "bench/skin"
			texmatcap = "bench/skin_material"
			texnormcap = "bench/skin_normal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.EQUIPMENT:
		{
			labeltext = text_get("bench/equipment")
			picker = bench_settings.equipment_picker
			texcap = "bench/equipment_tex"
			texmatcap = "bench/equipment_tex_material"
			texnormcap = "bench/equipment_tex_normal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.SPECIAL_BLOCK:
		{
			labeltext = text_get("bench/special_block")
			picker = bench_settings.special_block_picker
			texcap = "bench/special_block_tex"
			texmatcap = "bench/special_block_tex_material"
			texnormcap = "bench/special_block_tex_normal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.MODEL_PART:
		{
			labeltext = text_get("bench/model")
			picker = bench_settings.model_part_model_picker
			texcap = "bench/model_part_skin"
			texmatcap = "bench/model_part_skin_material"
			texnormcap = "bench/model_part_skin_normal"
			content_capwid = text_caption_width("bench/model_part", texcap, texmatcap, texnormcap)
			break
		}
	}

	// Picker and states
	var asset, states, armor, signtext, modelpart, blendcolor, dyed, pattern, partname, part, settingsh, pickerh;
	asset = mc_assets.model_name_map[?bench_settings.model_name]
	states = bench_settings.model_state
	armor = (asset.name = "armor")
	signtext = (bench_tab = e_bench_tab.SPECIAL_BLOCK && (asset.name = "sign" || asset.name = "hanging_sign"))
	modelpart = (bench_tab = e_bench_tab.MODEL_PART && bench_settings.model_file != null)
	dyed = state_vars_get_value(states, "dyed")
	blendcolor = (bench_settings.model_use_blend_color && (dyed = null || dyed = "true"))
	pattern = (bench_settings.pattern_type != "")
	partname = bench_settings.model_part_name
	part = (bench_tab = e_bench_tab.MODEL_PART) ? bench_settings.model_part : bench_settings.model_file

	// Calculate settings height
	settingsh = 8 + minecraft_asset_get_state_settings_height(asset)
	settingsh += (ui_large_height + 8) * (1 + 2 * project_render_material_maps)

	if (armor)
	{
		// The workbench combines the four armor material fields
		for (var i = 0; i < array_length(asset.default_state); i += 2)
			if (asset.default_state[i] != "helmet" && array_contains(armor_parts, asset.default_state[i]))
				settingsh -= 32
		
		settingsh += 40
	}

	if (signtext)
		settingsh += ui_small_height + 8
	if (modelpart)
		settingsh += 32
	if (blendcolor)
		settingsh += ui_small_height + 8
	if (pattern)
		settingsh += 40
		
	settingsh = max(bench_settings_height_min, settingsh)

	pickerh = bench_get_list_height(settingsh)
	draw_asset_picker(bench_settings.model_tex, picker, asset.name, states, dx, dy, dw, pickerh, labeltext)
	
	dy += pickerh + 8

	// Model part
	if (modelpart)
	{
		var text = minecraft_asset_get_name("model/part", bench_settings.model_part_name);
		draw_button_menu("bench/model_part", e_menu.LIST, dx, dy, dw, 24, bench_settings.model_part_name, text, action_bench_model_part_name, false, null, null, "", null, null, content_capwid)
		dy += 32
	}
	
	dy += draw_state_settings(asset, states, picker, action_bench_model_state, dx, dy, dw, armor)

	// Sign options
	if (signtext)
	{
		tab_set_columns(true, 2)

		tab_control(ui_small_height)
		if (draw_checkbox("bench/front_text", dx, dy, bench_settings.sign_front_text, null))
		{
			bench_settings.sign_front_text = !bench_settings.sign_front_text
			bench_settings.preview.update = true
		}
		tab_next()

		tab_control(ui_small_height)
		if (draw_checkbox("bench/back_text", dx, dy, bench_settings.sign_back_text, null))
		{
			bench_settings.sign_back_text = !bench_settings.sign_back_text
			bench_settings.preview.update = true
		}
		tab_next()

		tab_set_columns(false)
	}

	// Model blend color
	if (blendcolor)
	{
		panel_compact = true

		tab_control_color()
		draw_button_color("bench/model_color", dx, dy, dw, bench_settings.model_blend_color, bench_settings.model_blend_color_default, false, action_bench_model_blend_color)
		tab_next()

		panel_compact = false
	}

	// Skin
	var tex;
	content_text = res_eval(bench_settings.model_tex).display_name
	with (res_eval(bench_settings.model_tex))
		tex = res_get_model_texture(model_part_get_texture_name(part, app.bench_settings.model_texture_name_map))

	draw_button_menu(texcap, e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex, content_text, action_bench_model_tex, false, tex, null, "", null, null, content_capwid)
	dy += (ui_large_height + 8)

	if (project_render_material_maps)
	{
		// Skin (Material map)
		content_text = res_eval(bench_settings.model_tex_material).display_name
		with (res_eval(bench_settings.model_tex_material))
			tex = res_get_model_texture_material(model_part_get_texture_material_name(part, app.bench_settings.model_texture_material_name_map))

		draw_button_menu(texmatcap, e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex_material, content_text, action_bench_model_tex_material, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)

		// Skin (Normal map)
		content_text = res_eval(bench_settings.model_tex_normal).display_name
		with (res_eval(bench_settings.model_tex_normal))
			tex = res_get_model_texture_normal(model_part_get_texture_normal_name(part, app.bench_settings.model_texture_normal_name_map))

		draw_button_menu(texnormcap, e_menu.LIST, dx, dy, dw, ui_large_height, bench_settings.model_tex_normal, content_text, action_bench_model_tex_normal, false, tex, null, "", null, null, content_capwid)
		dy += (ui_large_height + 8)
	}

	// Pattern editor
	if (pattern)
	{
		tab_control_button_label()

		if (draw_button_label("bench/pattern_editor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_pattern_editor_show(bench_settings)

		tab_next()

		if (popup_current = popup_pattern_editor)
			current_microani.active.value = true
	}

	// Armor editor
	if (armor)
	{
		tab_control_button_label()

		if (draw_button_label("bench/armor_editor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_armor_editor_show(bench_settings)

		tab_next()

		if (popup_current = popup_armor_editor)
			current_microani.active.value = true
	}

	window_scroll_focus = string(picker.scroll)
}
