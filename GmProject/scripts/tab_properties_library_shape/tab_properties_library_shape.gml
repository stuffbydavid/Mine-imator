/// tab_properties_library_shape()

function tab_properties_library_shape()
{
	// Shape type
	tab_control_menu()
	draw_button_menu("libraryshapetype", e_menu.LIST, dx, dy, dw, 24, temp_edit.type, text_get("type" + temp_type_name_list[|temp_edit.type]), action_lib_shape_type)
	tab_next()
		
	// Texture
	var text, sprite;
	sprite = null
	if (temp_edit.shape_tex != null)
	{
		text = temp_edit.shape_tex.display_name
		if (temp_edit.shape_tex.type != e_tl_type.CAMERA)
			sprite = temp_edit.shape_tex.texture
	}
	else
		text = text_get("listnone")
			
	tab_control_menu(ui_large_height)
	draw_button_menu("libraryshapetex", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex, text, action_lib_shape_tex, false, sprite)
	tab_next()
			
	if (project_render_material_maps)
	{
		// Material texture
		if (temp_edit.shape_tex_material != null)
		{
			text = temp_edit.shape_tex_material.display_name
			sprite = temp_edit.shape_tex_material.texture
		}
		else
		{
			text = text_get("listnone")
			sprite = null
		}
			
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryshapetexmaterial", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex_material, text, action_lib_shape_tex_material, false, sprite)
		tab_next()
			
		// Normal texture
		if (temp_edit.shape_tex_normal != null)
		{
			text = temp_edit.shape_tex_normal.display_name
			sprite = temp_edit.shape_tex_normal.texture
		}
		else
		{
			text = text_get("listnone")
			sprite = null
		}
			
		tab_control_menu(ui_large_height)
		draw_button_menu("libraryshapetexnormal", e_menu.LIST, dx, dy, dw, ui_large_height, temp_edit.shape_tex_normal, text, action_lib_shape_tex_normal, false, sprite)
		tab_next()
	}
			
	// Mapped
	if (temp_edit.type = e_temp_type.CUBE || temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
	{
		// Advanced mode only
		if (setting_advanced_mode)
		{
			var mappedwid, exportwid;
			draw_set_font(font_label)
			mappedwid = 48 + string_width(text_get("libraryshapetexmapped"))
			draw_set_font(font_button)
			exportwid = 52 + string_width(text_get("libraryshapetexsavemap"))
					
			if (dw >= mappedwid + exportwid + 8)
			{
				tab_control_button_label()
				draw_checkbox("libraryshapetexmapped", dx, dy + 4, temp_edit.shape_tex_mapped, action_lib_shape_tex_mapped, "libraryshapetexmappedtip")
				if (draw_button_label("libraryshapetexsavemap", dx + dw, dy, exportwid, icons.TEXTURE_EXPORT, e_button.SECONDARY, null, e_anchor.RIGHT))
					action_lib_shape_save_map(temp_edit.type)
				tab_next()
			}
			else
			{
				tab_control_checkbox()
				draw_checkbox("libraryshapetexmapped", dx, dy, temp_edit.shape_tex_mapped, action_lib_shape_tex_mapped, "libraryshapetexmappedtip")
				tab_next()
						
				tab_control_button_label()
				if (draw_button_label("libraryshapetexsavemap", dx, dy, dw, icons.TEXTURE_EXPORT, e_button.SECONDARY))
					action_lib_shape_save_map(temp_edit.type)
				tab_next()
			}
		}
	}
			
	if (temp_edit.shape_tex || temp_edit.shape_tex_material || temp_edit.shape_tex_normal)
	{
		if (!temp_edit.shape_tex_mapped)
		{
			// Offset
			textfield_group_add("libraryshapetexhoffset", temp_edit.shape_tex_hoffset, 0, action_lib_shape_tex_hoffset, axis_edit, tab.library.tbx_shape_tex_hoffset)
			textfield_group_add("libraryshapetexvoffset", temp_edit.shape_tex_voffset, 0, action_lib_shape_tex_voffset, axis_edit, tab.library.tbx_shape_tex_voffset)
					
			tab_control_textfield_group(true, false)
			draw_textfield_group("libraryshapetexoffset", dx, dy, dw, 0.01, -no_limit, no_limit, 0, true, false, 3)
			tab_next()
					
			// Repeat
			textfield_group_add("libraryshapetexhrepeat", temp_edit.shape_tex_hrepeat, 1, action_lib_shape_tex_hrepeat, axis_edit, tab.library.tbx_shape_tex_hrepeat)
			textfield_group_add("libraryshapetexvrepeat", temp_edit.shape_tex_vrepeat, 1, action_lib_shape_tex_vrepeat, axis_edit, tab.library.tbx_shape_tex_vrepeat)
					
			tab_control_textfield_group(true, false)
			draw_textfield_group("libraryshapetexrepeat", dx, dy, dw, 0.01, 0, no_limit, 0, true, false, 3)
			tab_next()
		}
				
		// Mirror
		tab_control_checkbox()
		draw_checkbox("libraryshapetexhmirror", dx, dy, temp_edit.shape_tex_hmirror, action_lib_shape_tex_hmirror)
		tab_next()
				
		tab_control_checkbox()
		draw_checkbox("libraryshapetexvmirror", dx, dy, temp_edit.shape_tex_vmirror, action_lib_shape_tex_vmirror)
		tab_next()
	}
			
	// Closed
	if (temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER)
	{
		tab_control_checkbox()
		draw_checkbox("libraryshapeclosed", dx, dy, temp_edit.shape_closed, action_lib_shape_closed)
		tab_next()
	}
			
	// Invert
	tab_control_checkbox()
	draw_checkbox("libraryshapeinvert", dx, dy, temp_edit.shape_invert, action_lib_shape_invert)
	tab_next()
			
	if (temp_edit.type = e_temp_type.CONE || temp_edit.type = e_temp_type.CYLINDER || temp_edit.type = e_temp_type.SPHERE)
	{
		// Smooth
		tab_control_checkbox()
		draw_checkbox("libraryshapesmooth", dx, dy, temp_edit.shape_smooth, action_lib_shape_smooth)
		tab_next()
				
		// Detail
		tab_control_dragger()
		draw_dragger("libraryshapedetail", dx, dy, dragger_width, temp_edit.shape_detail, 0.25, temp_edit.type = e_temp_type.SPHERE ? 4 : 3, 256, 32, 1, tab.library.tbx_shape_detail, action_lib_shape_detail)
		tab_next()
	}
	else if (temp_edit.type = e_temp_type.SURFACE)
	{
		// Face camera
		tab_control_checkbox()
		draw_checkbox("libraryshapefacecamera", dx, dy, temp_edit.shape_face_camera, action_lib_shape_face_camera)
		tab_next()
	}
}