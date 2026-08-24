/// tab_frame_editor_texture_normal()

function tab_frame_editor_texture_normal()
{
	var texobj, name, tex;
	name = ""
	tex = null
	
	// Get material texture
	if (tl_edit.value_type[e_value_type.MATERIAL_TEXTURE] && tl_edit.temp != null)
	{
		switch (tl_edit.type)
		{
			case e_tl_type.CHARACTER:
			case e_tl_type.SPECIAL_BLOCK:
			case e_tl_type.MODEL:
			case e_tl_type.BODYPART:
			{
				name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "texnormal"
				
				var modelfile = tl_edit.temp.model_file;
				if (tl_edit.type = e_temp_type.BODYPART)
					modelfile = tl_edit.model_part
				
				with (tl_edit.temp)
				{
					texobj = temp_get_model_tex_normal_obj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
					tex = temp_get_model_tex_normal_preview(texobj, modelfile)
				}
				
				break
			}
			
			case e_tl_type.BLOCK:
			case e_tl_type.SCENERY:
			{
				name = "frameeditorblocktexnormal"
				with (tl_edit.temp)
					texobj = temp_get_block_tex_normal_obj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
				tex = texobj.block_preview_texture
				break
			}
			
			case e_tl_type.ITEM:
			{
				name = "frameeditoritemtexnormal"
				
				texobj = tl_edit.value[e_value.TEXTURE_NORMAL_OBJ];
				
				if (texobj = null)
					texobj = tl_edit.temp.item_tex_normal
				
				if (!res_is_ready(texobj))
					texobj = mc_res
				
				tex = texobj.block_preview_texture
				
				if (tex = null)
					tex = texobj.texture
				
				break
			}
			
			case e_tl_type.TEXT:
			{
				break // Text doesn't use textures
			}
			
			default: // Shapes
			{
				name = "frameeditorshapetexnormal"
				with (tl_edit.temp)
					texobj = temp_get_shape_tex_normal_obj(tl_edit.value[e_value.TEXTURE_NORMAL_OBJ])
				
				if (texobj != null) // Don't preview cameras
					tex = texobj.texture
				break
			}
		}
	}
	else if (tl_edit.type = e_tl_type.PATH)
	{
		// Paths don't use templates
		name = "frameeditorshapetexnormal"
		texobj = tl_edit.value[e_value.TEXTURE_NORMAL_OBJ]
		
		if (texobj = null)
			tex = spr_default_normal
		else
			tex = texobj.texture
	}
	else
		return 0
	
	if (name = "")
		return 0
	
	// Text to display
	var text;
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")
	
	if (tl_edit.value[e_value.TEXTURE_NORMAL_OBJ] = null)
		text = text_get("listdefault", text)
	
	tab_control_menu(ui_large_height)
	draw_button_menu(name, e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_NORMAL_OBJ], text, action_tl_frame_texture_normal_obj, false, tex)
	tab_next()
}
