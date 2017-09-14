/// tab_frame_editor_texture()

var texobj, name, tex;
texobj = tl_edit.value[e_value.TEXTURE_OBJ]
tex = null

if (!tl_edit.temp)
	return 0
	
switch (tl_edit.type)
{
	case "char":
	case "spblock":
	case "bodypart":
	{
		name = "frameeditor" + tl_edit.type + "tex"
		
		if (texobj = null || texobj.type = "camera" || (texobj.model_texture = null && texobj.model_texture_map = null))
			texobj = tl_edit.temp.skin
		
		with (texobj)
			tex = res_get_model_texture(model_get_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.model_part_name))
		break
	}
	
	case "block":
	case "scenery":
	{
		name = "frameeditorblocktex"
		if (texobj = null || texobj.type = "camera" || texobj.block_sheet_texture = null)
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
			if (texobj != null && texobj.type != "camera")
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
