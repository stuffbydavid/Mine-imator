/// tab_properties_library_model_part()

function tab_properties_library_model_part()
{
	var text;
	if (temp_edit.model_file != null)
		text = text_get("librarymodelpartof", minecraft_asset_get_name("modelpart", temp_edit.model_part_name), minecraft_asset_get_name("model", temp_edit.model_name))
	else
		text = text_get("librarymodelpartunknown")
			
	tab_control(24)
	draw_label_value(dx, dy, dw, 24, text_get("typemodelpart"), text)
			
	// Change
	if (draw_button_icon("librarymodelpartchange", dx + dw - 24, dy, 24, 24, object_editor.show && obj_edit = temp_edit, icons.PENCIL))
	{
		if (obj_edit = temp_edit)
			tab_toggle(object_editor)
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
				
		if (draw_button_label("librarypatterneditor", dx, dy, dw, null, e_button.SECONDARY))
			popup_pattern_editor_show(temp_edit)
				
		tab_next()
				
		if (popup = popup_armor_editor)
			current_microani.active.value = true
	}
			
	// Armor editor
	if (temp_edit.model_name = "armor")
	{
		tab_control_button_label()
				
		if (draw_button_label("libraryarmoreditor", dx, dy, dw, null, e_button.SECONDARY))
			popup_armor_editor_show(temp_edit)
				
		tab_next()
				
		if (popup = popup_armor_editor)
			current_microani.active.value = true
	}
			
	// Skin
	var tex = null;
	with (res_eval(temp_edit.model_tex))
		tex = res_get_model_texture(model_part_get_texture_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
	tab_control_menu(ui_large_height)
	draw_button_menu("librarymodelpartskin", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, res_eval(temp_edit.model_tex).display_name, action_lib_model_tex, false, tex)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Skin (Material map)
		tex = null
		with (res_eval(temp_edit.model_tex_material))
			tex = res_get_model_texture_material(model_part_get_texture_material_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
		tab_control_menu(ui_large_height)
		draw_button_menu("librarymodelpartskinmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, res_eval(temp_edit.model_tex_material).display_name, action_lib_model_tex_material, false, tex, null)
		tab_next()
			
		// Skin (Normal map)
		tex = null
		with (res_eval(temp_edit.model_tex_normal))
			tex = res_get_model_texture_normal(model_part_get_tex_normal_name(temp_edit.model_file, temp_edit.model_texture_name_map))
			
		tab_control_menu(ui_large_height)
		draw_button_menu("librarymodelpartskinnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, res_eval(temp_edit.model_tex_normal).display_name, action_lib_model_tex_normal, false, tex, null)
		tab_next()
	}
			
	// Model blend color
	if (temp_edit.model_use_blend_color)
	{
		tab_control_color()
		draw_button_color("librarymodelcolor", dx, dy, dw, temp_edit.model_blend_color, temp_edit.model_blend_color_default, false, action_lib_model_blend_color)
		tab_next()
	}
}
