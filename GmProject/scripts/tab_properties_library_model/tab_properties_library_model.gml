function tab_properties_library_model()
{
	if (temp_edit.model != null)
		content_text = temp_edit.model.display_name
	else
		content_text = text_get("list/none")
			
	// Model
	tab_control_menu()
	draw_button_menu("library/model", e_menu.LIST, dx, dy, dw, 24, temp_edit.model, content_text, action_lib_model, false, null)
	tab_next()
			
	// Texture
	var texobj, tex;
	with (temp_edit)
	{
		texobj = temp_get_model_texobj(null)
		tex = temp_get_model_tex_preview(texobj, model_file)
	}
			
	if (texobj != null)
		content_text = texobj.display_name
	else
		content_text = text_get("list/none")
			
	// Default
	if (temp_edit.model_tex = null)
		content_text = text_get("list/default", content_text)
			
	tab_control_menu(ui_large_height)
	draw_button_menu("library/model_tex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, content_text, action_lib_model_tex, false, tex)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Texture (Material map)
		with (temp_edit)
		{
			texobj = temp_get_model_tex_material_obj(null)
			tex = temp_get_model_tex_material_preview(texobj, model_file)
		}
			
		if (texobj != null)
			content_text = texobj.display_name
		else
			content_text = text_get("list/none")
			
		// Default
		if (temp_edit.model_tex_material = null)
			content_text = text_get("list/default", content_text)
			
		tab_control_menu(ui_large_height)
		draw_button_menu("library/model_tex_material", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, content_text, action_lib_model_tex_material, false, tex)
		tab_next()
			
		// Texture (Normal map)
		with (temp_edit)
		{
			texobj = temp_get_model_tex_normal_obj(null)
			tex = temp_get_model_tex_normal_preview(texobj, model_file)
		}
			
		if (texobj != null)
			content_text = texobj.display_name
		else
			content_text = text_get("list/none")
			
		// Default
		if (temp_edit.model_tex_normal = null)
			content_text = text_get("list/default", content_text)
			
		tab_control_menu(ui_large_height)
		draw_button_menu("library/model_tex_normal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, content_text, action_lib_model_tex_normal, false, tex)
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
