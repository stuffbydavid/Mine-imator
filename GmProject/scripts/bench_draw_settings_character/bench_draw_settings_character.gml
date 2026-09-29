function bench_draw_settings_character()
{
	var labeltext, list, part, texcap, texmatcap, texnormcap;
	
	switch (bench_tab)
	{
		case e_bench_tab.CHARACTER:
		{
			labeltext = text_get("benchmodel")
			list = bench_settings.char_list
			part = bench_settings.model_file
			texcap = "benchskin"
			texmatcap = "benchskinmaterial"
			texnormcap = "benchskinnormal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.EQUIPMENT:
		{
			labeltext = text_get("benchequipment")
			list = bench_settings.equipment_list
			part = bench_settings.model_file
			texcap = "benchequipmenttex"
			texmatcap = "benchequipmenttexmaterial"
			texnormcap = "benchequipmenttexnormal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.SPECIAL_BLOCK:
		{
			labeltext = text_get("benchspblock")
			list = bench_settings.special_block_list
			part = bench_settings.model_file
			texcap = "benchspblocktex"
			texmatcap = "benchspblocktexmaterial"
			texnormcap = "benchspblocktexnormal"
			content_capwid = text_caption_width(texcap, texmatcap, texnormcap)
			break
		}
		
		case e_bench_tab.MODEL_PART:
		{
			labeltext = text_get("benchmodel")
			list = bench_settings.model_part_model_list
			part = bench_settings.model_part
			texcap = "benchmodelpartskin"
			texmatcap = "benchmodelpartskinmaterial"
			texnormcap = "benchmodelpartskinnormal"
			content_capwid = text_caption_width("benchmodelpart", texcap, texmatcap, texnormcap)
			break
		}
	}

	// List
	tab_control(bench_list_height(list))
	sortlist_draw(list, dx, dy, dw, tab_control_h, bench_settings.model_name, false, labeltext)
	tab_next()
	menu_filter = list.search_tbx.text
	menu_filter_normal = sortlist_column_get(list, bench_settings.model_name, 0)

	// States
	var model, statelen;
	model = mc_assets.model_name_map[?bench_settings.model_name]
	statelen = array_length(bench_settings.model_state)
	
	if (bench_settings.model_name = "armor")
		content_capwid = max(content_capwid, text_caption_width("bencharmorvariant"))

	for (var i = 0; i < statelen; i += 2)
	{
		var state = bench_settings.model_state[i];
		if (bench_settings.model_name = "armor" && array_contains(armor_parts, state))
			continue
		
		content_capwid = max(content_capwid, text_caption_width(minecraft_asset_get_name("modelstate", state)))
	}

	// Checkboxes
	tab_set_columns(true, 2)

	for (var i = 0; i < statelen; i += 2)
	{
		if (bench_settings.model_state[i + 1] != "true" && bench_settings.model_state[i + 1] != "false")
			continue

		var state = bench_settings.model_state[i];
		menu_model_current = model
		menu_model_state_current = model.states_map[?state]

		tab_control(ui_small_height)

		if (draw_checkbox("modelstate" + state, dx, dy, bench_settings.model_state[i + 1] = "true", null))
		{
			menu_model_state = menu_model_state_current

			if (bench_settings.model_state[i + 1] = "true")
				action_bench_model_state("false")
			else
				action_bench_model_state("true")
		}

		tab_next()
	}

	tab_set_columns(false)

	// Menus
	for (var i = 0; i < statelen; i += 2)
	{
		if (bench_settings.model_state[i + 1] = "true" || bench_settings.model_state[i + 1] = "false")
			continue

		var state = bench_settings.model_state[i];
		if (bench_settings.model_name = "armor" && array_contains(armor_parts, state))
		{
			if (state != "helmet")
				continue
			
			var variant = state_vars_get_value(bench_settings.model_state, "helmet");
			if (state_vars_get_value(bench_settings.model_state, "chestplate") != variant ||
				state_vars_get_value(bench_settings.model_state, "leggings") != variant ||
				state_vars_get_value(bench_settings.model_state, "boots") != variant)
				variant = "multiple"
			
			menu_model_current = null
			menu_model_state_current = model.states_map[?"helmet"]
			menu_model_armor_variant = true
			
			draw_button_menu("bencharmorvariant", e_menu.LIST, dx, dy, dw, 24, variant, variant = "multiple" ? text_get("listmultiple") : minecraft_asset_get_name("modelstatevalue", variant), action_bench_model_state, false, null, null, "", null, null, content_capwid)
			if (!keyboard_check(vk_control) || mouse_wheel = 0)
				menu_model_armor_variant = false
			
			dy += 32
			
			continue
		}
		
		menu_model_current = model
		menu_model_state_current = model.states_map[?state]

		draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", bench_settings.model_state[i + 1]), action_bench_model_state, false, null, null, "", null, null, content_capwid)
		dy += 32
	}

	menu_model_current = null
	menu_filter = ""
	menu_filter_normal = ""

	// Model part
	if (bench_tab = e_bench_tab.MODEL_PART && bench_settings.model_file != null)
	{
		draw_button_menu("benchmodelpart", e_menu.LIST, dx, dy, dw, 24, bench_settings.model_part_name, minecraft_asset_get_name("modelpart", bench_settings.model_part_name), action_bench_model_part_name, false, null, null, "", null, null, content_capwid)
		dy += 32
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

	// Model blend color
	if (bench_settings.model_use_blend_color)
	{
		panel_compact = true

		tab_control_color()
		draw_button_color("benchmodelcolor", dx, dy, dw, bench_settings.model_blend_color, bench_settings.model_blend_color_default, false, action_bench_model_blend_color)
		tab_next()

		panel_compact = false
	}

	// Pattern editor
	if (bench_settings.pattern_type != "")
	{
		tab_control_button_label()

		if (draw_button_label("benchpatterneditor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_pattern_editor_show(bench_settings)

		tab_next()

		if (popup_current = popup_pattern_editor)
			current_microani.active.value = true
	}

	// Armor editor
	if (bench_settings.model_name = "armor")
	{
		tab_control_button_label()

		if (draw_button_label("bencharmoreditor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_armor_editor_show(bench_settings)

		tab_next()

		if (popup_current = popup_armor_editor)
			current_microani.active.value = true
	}

	window_scroll_focus = string(list.scroll)
}
