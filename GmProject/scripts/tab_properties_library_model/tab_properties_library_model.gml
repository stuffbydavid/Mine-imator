/// tab_properties_library_model()

function tab_properties_library_model()
{
	var text;
	if (temp_edit.model != null)
		text = temp_edit.model.display_name
	else
		text = text_get("listnone")
			
	// Model
	tab_control_menu()
	draw_button_menu("librarymodel", e_menu.LIST, dx, dy, dw, 24, temp_edit.model, text, action_lib_model, false, null)
	tab_next()
			
	// Texture
	var texobj, tex;
	with (temp_edit)
	{
		texobj = temp_get_model_texobj(null)
		tex = temp_get_model_tex_preview(texobj, model_file)
	}
			
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")
			
	// Default
	if (temp_edit.model_tex = null)
		text = text_get("listdefault", text)
			
	tab_control_menu(ui_large_height)
	draw_button_menu("librarymodeltex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex, text, action_lib_model_tex, false, tex)
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
			text = texobj.display_name
		else
			text = text_get("listnone")
			
		// Default
		if (temp_edit.model_tex_material = null)
			text = text_get("listdefault", text)
			
		tab_control_menu(ui_large_height)
		draw_button_menu("librarymodeltexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_material, text, action_lib_model_tex_material, false, tex)
		tab_next()
			
		// Texture (Normal map)
		with (temp_edit)
		{
			texobj = temp_get_model_tex_normal_obj(null)
			tex = temp_get_model_tex_normal_preview(texobj, model_file)
		}
			
		if (texobj != null)
			text = texobj.display_name
		else
			text = text_get("listnone")
			
		// Default
		if (temp_edit.model_tex_normal = null)
			text = text_get("listdefault", text)
			
		tab_control_menu(ui_large_height)
		draw_button_menu("librarymodeltexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.model_tex_normal, text, action_lib_model_tex_normal, false, tex)
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