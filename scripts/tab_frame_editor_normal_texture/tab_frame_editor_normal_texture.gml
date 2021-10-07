/// tab_frame_editor_normal_texture()

function tab_frame_editor_normal_texture()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_TEXTURE])
		return 0
	
	var texobj, name, tex;
	tex = null
	
	if (tl_edit.temp = null)
		return 0
		
	switch (tl_edit.type)
	{
		case e_tl_type.CHARACTER:
		case e_tl_type.SPECIAL_BLOCK:
		case e_tl_type.MODEL:
		case e_tl_type.BODYPART:
		{
			name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "normaltex"
			
			var modelfile = tl_edit.temp.model_file;
			if (tl_edit.type = e_temp_type.BODYPART)
				modelfile = tl_edit.model_part
			
			with (tl_edit.temp)
			{
				texobj = temp_get_model_texobj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
				tex = temp_get_model_tex_preview(texobj, modelfile)
			}
			
			break
		}
		
		case e_tl_type.BLOCK:
		case e_tl_type.SCENERY:
		{
			name = "frameeditorblocknormaltex"
			with (tl_edit.temp)
				texobj = temp_get_block_tex_normal_obj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
			tex = texobj.block_preview_texture
			break
		}
		
		default: // Shapes
		{
			name = "frameeditorshapenormaltex"
			with (tl_edit.temp)
				texobj = temp_get_shape_tex_normal_obj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
			
			if (texobj != null) // Don't preview cameras
				tex = texobj.texture
			break
		}
	}
	
	// Text to display
	var text;
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")
	
	if (tl_edit.value[e_value.TEXTURE_NORMAL_OBJ] = null)
		text = text_get("listdefault", text)
	
	tab_control_menu(32)
	draw_button_menu(name, e_menu.LIST, dx, dy, dw, 32, tl_edit.value[e_value.TEXTURE_NORMAL_OBJ], text, action_tl_frame_texture_normal_obj, false, tex)
	tab_next()
}
