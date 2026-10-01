/// @desc Common template settings for built-in models.

function tab_properties_library_character()
{
	switch (temp_edit.type)
	{
		case e_temp_type.CHARACTER: content_text = "library/char_model"; break
		case e_temp_type.EQUIPMENT: content_text = "library/equipment_model"; break
		case e_temp_type.SPECIAL_BLOCK: content_text = "library/special_block_model"; break
		default: return 0
	}
	
	// Model
	tab_control(24)
	draw_label_value(dx, dy, dw - 32, 24, text_get(content_text), temp_edit.model_file != null ? string(minecraft_asset_get_name("model", temp_edit.model_file.name)) : "")
			
	// Change
	if (draw_button_icon("library/char_model_change", dx + dw - 24, dy, 24, 24, object_editor.raised && obj_edit = temp_edit, icons.PENCIL, null, false, "tooltip/change_model"))
	{
		if (obj_edit = temp_edit)
			tab_toggle(object_editor, true)
		else
		{
			obj_edit = temp_edit
			tab_show(object_editor, true)
		}
	}
			
	tab_next()
			
	// Pattern editor
	if (temp_edit.pattern_type != "")
	{
		tab_control_button_label()
				
		if (draw_button_label("bench/pattern_editor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_pattern_editor_show(temp_edit)
				
		tab_next()
				
		if (popup_current = popup_pattern_editor)
			current_microani.active.value = true
	}
			
	// Armor editor
	if (temp_edit.model_name = "armor")
	{
		tab_control_button_label()
				
		if (draw_button_label("bench/armor_editor", dx, dy, dw, icons.CUSTOMIZATION, e_button.SECONDARY))
			popup_armor_editor_show(temp_edit)
				
		tab_next()
				
		if (popup_current = popup_armor_editor)
			current_microani.active.value = true
	}
			
	// Skin
	var tex = null;
	with (res_eval(temp_edit.model_tex))
		tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
	tab_control_menu(ui_large_height)
	draw_button_menu((temp_edit.type = e_temp_type.EQUIPMENT ? "library/equipment_tex" : (temp_edit.type = e_temp_type.SPECIAL_BLOCK ? "library/special_block_tex" : "library/skin")), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, res_eval(temp_edit.model_tex).display_name, action_lib_model_tex, false, tex, null)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Skin (Material map)
		tex = null
		with (res_eval(temp_edit.model_tex_material))
			tex = res_get_model_texture_material(model_part_get_texture_material_name(temp_edit.model_file, temp_edit.model_texture_material_name_map))
			
		tab_control_menu(ui_large_height)
		draw_button_menu((temp_edit.type = e_temp_type.EQUIPMENT ? "library/equipment_tex_material" : (temp_edit.type = e_temp_type.SPECIAL_BLOCK ? "library/special_block_tex_material" : "library/skin_material")), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, res_eval(temp_edit.model_tex_material).display_name, action_lib_model_tex_material, false, tex, null)
		tab_next()
			
		// Skin (Normal map)
		tex = null
		with (res_eval(temp_edit.model_tex_normal))
			tex = res_get_model_texture_normal(model_part_get_texture_normal_name(temp_edit.model_file, temp_edit.model_texture_normal_name_map))
			
		tab_control_menu(ui_large_height)
		draw_button_menu((temp_edit.type = e_temp_type.EQUIPMENT ? "library/equipment_tex_normal" : (temp_edit.type = e_temp_type.SPECIAL_BLOCK ? "library/special_block_tex_normal" : "library/skin_normal")), e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, res_eval(temp_edit.model_tex_normal).display_name, action_lib_model_tex_normal, false, tex, null)
		tab_next()
	}
			
	// Model blend color
	if (temp_edit.model_use_blend_color)
	{
		tab_control_color()
		draw_button_color("library/model_color", dx, dy, dw, temp_edit.model_blend_color, temp_edit.model_blend_color_default, false, action_lib_model_blend_color)
		tab_next()
	}
}
