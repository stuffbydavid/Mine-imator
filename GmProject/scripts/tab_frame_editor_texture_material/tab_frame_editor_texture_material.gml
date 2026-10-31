function tab_frame_editor_texture_material()
{
	var tex, sliders, texobj;
	content_name = ""
	tex = null
	sliders = false
	
	// Get material texture
	if (tl_edit.value_type[e_value_type.MATERIAL_TEXTURE] && tl_edit.temp != null)
	{	
		switch (tl_edit.type)
		{
			case e_tl_type.CHARACTER:
			case e_tl_type.EQUIPMENT:
			case e_tl_type.SPECIAL_BLOCK:
			case e_tl_type.MODEL:
			case e_tl_type.MODEL_PART:
			{
				content_name = "frame_editor/" + tl_type_name_list[|tl_edit.type] + "_tex_material"
				
				var modelfile = tl_edit.temp.model_file;
				if (tl_edit.type = e_temp_type.MODEL_PART)
					modelfile = tl_edit.model_part
				
				with (tl_edit.temp)
				{
					texobj = temp_get_model_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
					tex = temp_get_model_tex_material_preview(texobj, modelfile)
				}
				
				if (tex = null || texobj = mc_res || texobj = null)
					sliders = true
				
				break
			}
			
			case e_tl_type.BLOCK:
			case e_tl_type.SCENERY:
			{
				content_name = "frame_editor/block_tex_material"
				with (tl_edit.temp)
					texobj = temp_get_block_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
				
				tex = texobj.block_preview_texture
				
				if (texobj = mc_res)
					sliders = true
				
				break
			}
			
			case e_tl_type.ITEM:
			{
				content_name = "frame_editor/item_tex_material"
				
				texobj = tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ]
				
				if (texobj = null)
					texobj = tl_edit.temp.item_tex_material
				texobj = res_eval(texobj)
				
				tex = texobj.block_preview_texture
				
				if (tex = null)
					tex = texobj.texture
				
				if (texobj = mc_res)
					sliders = true
				
				break
			}
			
			case e_tl_type.TEXT:
			{
				sliders = true // Text doesn't use textures, always use surface sliders
				break
			}
			
			default: // Shapes
			{
				content_name = "frame_editor/shape_tex_material"
				with (tl_edit.temp)
					texobj = temp_get_shape_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
				
				if (texobj != null) // Don't preview cameras
					tex = texobj.texture
				
				if (texobj = null)
					sliders = true
				
				break
			}
		}
	}
	else if (tl_edit.type = e_tl_type.PATH)
	{
		// Paths don't use templates
		content_name = "frame_editor/shape_tex_material"
		texobj = tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ]
			
		if (texobj != null)
			tex = texobj.texture
			
		if (texobj = null)
			sliders = true
	}
	else
		sliders = true
		
	if (content_name != "")
	{
		// Text to display
		if (texobj != null)
			content_text = texobj.display_name
		else
			content_text = text_get("list/none")
			
		if (tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ] = null || tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ] = project_pack_res)
			content_text = text_get("list/default", content_text)
			
		if (project_render_material_maps)
		{
			tab_control_menu(ui_large_height)
			draw_button_menu(content_name, e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ], content_text, action_tl_frame_texture_material_obj, false, tex)
			tab_next()
		}
	}
	
	// Sliders for manual edit
	if (sliders)
	{
		// Roughness
		tab_control_meter()
		draw_meter("frame_editor/roughness", dx, dy, dw, round(tl_edit.value[e_value.ROUGHNESS] * 100), 0, 100, 100, 1, tab.material.tbx_roughness, action_tl_frame_roughness)
		tab_next()
		
		// Metallic
		tab_control_meter()
		draw_meter("frame_editor/metallic", dx, dy, dw, round(tl_edit.value[e_value.METALLIC] * 100), 0, 100, 0, 1, tab.material.tbx_metallic, action_tl_frame_metallic)
		tab_next()
		
		// Emissive
		tab_control_dragger()
		draw_dragger("frame_editor/emissive", dx, dy, dragger_width, round(tl_edit.value[e_value.EMISSIVE] * 100), .1, 0, no_limit, 0, 1, tab.material.tbx_emissive, action_tl_frame_emissive)
		tab_next()
	}
}
