function tab_frame_editor_texture()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_TEXTURE])
		return 0
	
	var tex, texobj;
	tex = null
	content_name = ""
	
	if (tl_edit.temp != null)
	{
		switch (tl_edit.type)
		{
			case e_tl_type.CHARACTER:
			case e_tl_type.EQUIPMENT:
			case e_tl_type.SPECIAL_BLOCK:
			case e_tl_type.MODEL:
			case e_tl_type.MODEL_PART:
			{
				content_name = "frame_editor/" + tl_type_name_list[|tl_edit.type] + "_tex"
				
				var modelfile = tl_edit.temp.model_file;
				if (tl_edit.type = e_tl_type.MODEL_PART)
					modelfile = tl_edit.model_part
				
				with (tl_edit.temp)
				{
					texobj = temp_get_model_texobj(tl_edit.value[e_value.TEXTURE_OBJ])
					tex = temp_get_model_tex_preview(texobj, modelfile)
				}
				
				break
			}
			
			case e_tl_type.BLOCK:
			case e_tl_type.SCENERY:
			{
				content_name = "frame_editor/block_tex"
				with (tl_edit.temp)
					texobj = temp_get_block_texobj(tl_edit.value[e_value.TEXTURE_OBJ])
				tex = texobj.block_preview_texture
				break
			}
			
			case e_tl_type.ITEM:
			{
				content_name = "frame_editor/item_tex"
				
				texobj = tl_edit.value[e_value.TEXTURE_OBJ]
				
				if (texobj = null)
					texobj = tl_edit.temp.item_tex
				texobj = res_eval(texobj)
				
				tex = texobj.block_preview_texture
				
				if (tex = null)
					tex = texobj.texture
				
				break
			}
			
			case e_tl_type.TEXT:
				break // Text doesn't use textures
			
			default: // Shapes
			{
				content_name = "frame_editor/shape_tex"
				with (tl_edit.temp)
					texobj = temp_get_shape_texobj(tl_edit.value[e_value.TEXTURE_OBJ])
				
				if (texobj != null && texobj.type != e_tl_type.CAMERA) // Don't preview cameras
					tex = texobj.texture
				
				break
			}
		}
	}
	
	// Paths don't use templates
	if (tl_edit.type = e_tl_type.PATH)
	{
		content_name = "frame_editor/shape_tex"
		texobj = tl_edit.value[e_value.TEXTURE_OBJ]
		
		if (texobj = null)
			tex = spr_shape
		else
			tex = texobj.texture
	}
	else if (tl_edit.type = e_tl_type.STRUCTURE)
	{
		content_name = "frame_editor/block_tex"
		texobj = tl_edit.value[e_value.TEXTURE_OBJ]
		texobj = res_eval(texobj)
		tex = texobj.block_preview_texture
	}
	
	if (content_name = "")
		return 0
	
	// Text to display
	if (texobj != null)
		content_text = texobj.display_name
	else
		content_text = text_get("list/none")
	
	if (tl_edit.value[e_value.TEXTURE_OBJ] = null || (tl_edit.type != e_tl_type.STRUCTURE && tl_edit.value[e_value.TEXTURE_OBJ] = project_pack_res))
		content_text = text_get("list/default", content_text)
	
	tab_control_menu(ui_large_height)
	draw_button_menu(content_name, e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_OBJ], content_text, action_tl_frame_texture_obj, false, tex)
	tab_next()
}
