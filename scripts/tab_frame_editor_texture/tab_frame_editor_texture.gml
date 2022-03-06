/// tab_frame_editor_texture()

function tab_frame_editor_texture()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_TEXTURE])
		return 0
	
	var texobj, name, tex;
	tex = null
	name = ""
	
	if (tl_edit.temp != null)
	{
		switch (tl_edit.type)
		{
			case e_tl_type.CHARACTER:
			case e_tl_type.SPECIAL_BLOCK:
			case e_tl_type.MODEL:
			case e_tl_type.BODYPART:
			{
				name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "tex"
				
				var modelfile = tl_edit.temp.model_file;
				if (tl_edit.type = e_temp_type.BODYPART)
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
				name = "frameeditorblocktex"
				with (tl_edit.temp)
					texobj = temp_get_block_texobj(tl_edit.value[e_value.TEXTURE_OBJ])
				tex = texobj.block_preview_texture
				break
			}
			
			case e_tl_type.ITEM:
			{
				name = "frameeditoritemtex"
				
				var texobj = tl_edit.value[e_value.TEXTURE_OBJ];
				
				if (texobj = null)
					texobj = tl_edit.temp.item_tex
				
				if (!res_is_ready(texobj))
					texobj = mc_res
				
				tex = texobj.block_preview_texture
				
				if (tex = null)
					tex = texobj.texture
				
				break
			}
			
			default: // Shapes
			{
				name = "frameeditorshapetex"
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
		name = "frameeditorshapetex"
		texobj = tl_edit.value[e_value.TEXTURE_OBJ]
		
		if (texobj = null)
			tex = spr_shape
		else
			tex = texobj.texture
	}
	
	if (name = "")
		return 0
	
	// Text to display
	var text;
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")
	
	if (tl_edit.value[e_value.TEXTURE_OBJ] = null)
		text = text_get("listdefault", text)
	
	tab_control_menu(32)
	draw_button_menu(name, e_menu.LIST, dx, dy, dw, 32, tl_edit.value[e_value.TEXTURE_OBJ], text, action_tl_frame_texture_obj, false, tex)
	tab_next()
}
