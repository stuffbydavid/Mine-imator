/// tab_frame_editor_texture_material()

function tab_frame_editor_texture_material()
{
	var texobj, name, tex, sliders;
	name = ""
	tex = null
	sliders = false
	
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
				name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "texmaterial"
				
				var modelfile = tl_edit.temp.model_file;
				if (tl_edit.type = e_temp_type.BODYPART)
					modelfile = tl_edit.model_part
				
				with (tl_edit.temp)
				{
					texobj = temp_get_model_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
					tex = temp_get_model_tex_material_preview(texobj, modelfile)
				}
				
				if (texobj = mc_res || texobj = null)
					sliders = true
				
				break
			}
			
			case e_tl_type.BLOCK:
			case e_tl_type.SCENERY:
			{
				name = "frameeditorblocktexmaterial"
				with (tl_edit.temp)
					texobj = temp_get_block_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
				
				if (!res_is_ready(texobj))
					texobj = mc_res
				tex = texobj.block_preview_texture
				
				if (texobj = mc_res)
					sliders = true
				
				break
			}
			
			case e_tl_type.ITEM:
			{
				name = "frameeditoritemtexmaterial"
				
				texobj = tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ];
				
				if (texobj = null)
					texobj = tl_edit.temp.item_tex_material
				
				if (!res_is_ready(texobj))
					texobj = mc_res
				
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
				name = "frameeditorshapetexmaterial"
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
		name = "frameeditorshapetexmaterial"
		texobj = tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ]
			
		if (texobj = null)
			tex = spr_default_material
		else
			tex = texobj.texture
			
		if (texobj = null)
			sliders = true
	}
	else
		sliders = true
		
	if (name != "")
	{
		// Text to display
		var text;
		if (texobj != null)
			text = texobj.display_name
		else
			text = text_get("listnone")
			
		if (tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ] = null)
			text = text_get("listdefault", text)
			
		if (project_render_material_maps)
		{
			tab_control_menu(ui_large_height)
			draw_button_menu(name, e_menu.LIST, dx, dy, dw, ui_large_height, tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ], text, action_tl_frame_texture_material_obj, false, tex)
			tab_next()
		}
	}
	
	// Sliders for manual edit
	if (sliders)
	{
		// Roughness
		tab_control_meter()
		draw_meter("frameeditorroughness", dx, dy, dw, round(tl_edit.value[e_value.ROUGHNESS] * 100), 0, 100, 100, 1, tab.material.tbx_roughness, action_tl_frame_roughness)
		tab_next()
		
		// Metallic
		tab_control_meter()
		draw_meter("frameeditormetallic", dx, dy, dw, round(tl_edit.value[e_value.METALLIC] * 100), 0, 100, 0, 1, tab.material.tbx_metallic, action_tl_frame_metallic)
		tab_next()
		
		// Emissive
		tab_control_dragger()
		draw_dragger("frameeditoremissive", dx, dy, dragger_width, round(tl_edit.value[e_value.EMISSIVE] * 100), .1, 0, no_limit, 0, 1, tab.material.tbx_emissive, action_tl_frame_emissive)
		tab_next()
	}
}
