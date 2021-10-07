/// tab_frame_editor_material_texture()

function tab_frame_editor_material_texture()
{
	if (!tl_edit.value_type[e_value_type.MATERIAL_TEXTURE])
		return 0
	
	var texobj, name, tex, nomattex;
	tex = null
	nomattex = false
	
	if (tl_edit.temp = null)
		return 0
		
	switch (tl_edit.type)
	{
		case e_tl_type.CHARACTER:
		case e_tl_type.SPECIAL_BLOCK:
		case e_tl_type.MODEL:
		case e_tl_type.BODYPART:
		{
			name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "materialtex"
			
			var modelfile = tl_edit.temp.model_file;
			if (tl_edit.type = e_temp_type.BODYPART)
				modelfile = tl_edit.model_part
			
			with (tl_edit.temp)
			{
				texobj = temp_get_model_texobj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
				tex = temp_get_model_tex_preview(texobj, modelfile)
			}
			
			nomattex = true
			
			break
		}
		
		case e_tl_type.BLOCK:
		case e_tl_type.SCENERY:
		{
			name = "frameeditorblockmaterialtex"
			with (tl_edit.temp)
				texobj = temp_get_block_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
			tex = texobj.block_preview_texture
			
			if (texobj = mc_res)
				nomattex = true
			
			break
		}
		
		default: // Shapes
		{
			name = "frameeditorshapematerialtex"
			with (tl_edit.temp)
				texobj = temp_get_shape_tex_material_obj(tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ])
			
			if (texobj != null) // Don't preview cameras
				tex = texobj.texture
			
			if (texobj = null)
				nomattex = true
			
			break
		}
	}
	
	// Text to display
	var text;
	if (texobj != null)
		text = texobj.display_name
	else
		text = text_get("listnone")
	
	if (tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ] = null)
		text = text_get("listdefault", text)
	
	tab_control_menu(32)
	draw_button_menu(name, e_menu.LIST, dx, dy, dw, 32, tl_edit.value[e_value.TEXTURE_MATERIAL_OBJ], text, action_tl_frame_texture_material_obj, false, tex)
	tab_next()
	
	// Sliders for manual edit
	if (nomattex)
	{
		// Roughness
		tab_control_meter()
		draw_meter("frameeditorroughness", dx, dy, dw, round(tl_edit.value[e_value.ROUGHNESS] * 100), 60, 0, 100, 100, 1, tab.material.tbx_roughness, action_tl_frame_roughness)
		tab_next()
		
		// Metallic
		tab_control_meter()
		draw_meter("frameeditormetallic", dx, dy, dw, round(tl_edit.value[e_value.METALLIC] * 100), 60, 0, 100, 0, 1, tab.material.tbx_metallic, action_tl_frame_metallic)
		tab_next()
	
		// Emission
		tab_control_meter()
		draw_meter("frameeditoremission", dx, dy, dw, round(tl_edit.value[e_value.BRIGHTNESS] * 100), 60, 0, 100, 0, 1, tab.material.tbx_brightness, action_tl_frame_brightness)
		tab_next()
	}
}
