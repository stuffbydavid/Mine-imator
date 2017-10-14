/// tab_frame_editor_texture()

var texobj, name, tex;
texobj = tl_edit.value[e_value.TEXTURE_OBJ]
tex = null

if (!tl_edit.temp)
	return 0
	
switch (tl_edit.type)
{
	case e_temp_type.CHARACTER:
	case e_temp_type.SPECIAL_BLOCK:
	case e_temp_type.BODYPART:
	{
		name = "frameeditor" + tl_type_name_list[|tl_edit.type] + "tex"
		
		if (texobj = null || texobj.type = e_tl_type.CAMERA || (texobj.model_texture = null && texobj.model_texture_map = null))
			texobj = tl_edit.temp.skin
		
		if (tl_edit.type = e_temp_type.BODYPART)
		{
			with (texobj)
				tex = res_get_model_texture(model_part_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.model_part))
		}
		else
		{
			with (texobj)
				tex = res_get_model_texture(model_part_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.temp.model_file))
		}
		break
	}
	
	case e_temp_type.BLOCK:
	case e_temp_type.SCENERY:
	{
		name = "frameeditorblocktex"
		if (texobj = null || texobj.type = e_tl_type.CAMERA || texobj.block_sheet_texture = null)
			texobj = tl_edit.temp.block_tex
		tex = texobj.block_preview_texture
		break
	}
	
	default: // Shapes
	{
		name = "frameeditorshapetex"
		with (tl_edit.temp)
		{
			texobj = temp_get_shape_texobj(texobj)
			if (texobj != null && texobj.type != e_tl_type.CAMERA)
				tex = texobj.texture
		}
		break
	}
}

var text;
if (texobj != null)
	text = texobj.display_name
else
	text = text_get("listnone")

if (tl_edit.value[e_value.TEXTURE_OBJ] = null)
	text = text_get("frameeditortexturedefault", text)

tab_control(40)
draw_button_menu(name, e_menu.LIST, dx, dy, dw, 40, tl_edit.value[e_value.TEXTURE_OBJ], text, action_tl_frame_texture_obj, tex)
tab_next()
