/// tab_frame_editor_texture()

var texobj, name, text, tex;
texobj = tl_edit.value[e_value.TEXTURE_OBJ]
text = text_get("listnone")
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
		
		//if (!texobj || texobj.type = "camera" || (!texobj.mob_texture && !texobj.model_texture_map)) // TODO
		//	texobj = tl_edit.temp.char_skin
		
		with (texobj)
			tex = res_get_model_texture(model_get_texture_name(tl_edit.temp.model_texture_name_map, tl_edit.model_part_name))
		break
	}
	
	case "block":
	case "scenery":
	{
		name = "frameeditorblocktex"
		if (!texobj || texobj.type = "camera" || texobj.block_sheet_texture = null)
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
			if (texobj && texobj.type != "camera")
				tex = texobj.texture
		}
		break
	}
}

if (texobj)
	text = texobj.display_name
if (tl_edit.value[e_value.TEXTURE_OBJ] < 0)
	text = text_get("frameeditortexturedefault", text)

tab_control(40)
draw_button_menu(name, e_menu.LIST, dx, dy, dw, 40, tl_edit.value[e_value.TEXTURE_OBJ], text, action_tl_frame_texture_obj, tex)
tab_next()
