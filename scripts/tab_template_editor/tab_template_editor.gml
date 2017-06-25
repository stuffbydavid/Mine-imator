/// tab_template_editor()

if (!instance_exists(temp_edit))
{
	tab_close(tab)
	return 0
}

switch (temp_edit.type)
{
	case "char":
		draw_label(text_get("templateeditorcharmodel") + ":", dx, dy)
		sortlist_draw(tab.char_list, dx, dy + 22, dw, dh - 90, temp_edit.char_model)
		break
		
	case "block":
		draw_label(text_get("templateeditorblock") + ":", dx, dy)
		tab.block_list.block_data = temp_edit.block_data
		sortlist_draw(tab.block_list, dx, dy + 22, dw, dh - 120, temp_edit.block_id)
		draw_meter("templateeditorblockdata", dx, dy + dh - 70, dw, temp_edit.block_data, 50, 0, 15, 0, 1, tab.tbx_block_data, action_lib_block_data)
		break
	
	case "item":
		var res = temp_edit.item_tex;
		if (!res.ready)
			res = res_def
		
		if (res.type != "itemsheet")
		{
			tab_close(tab)
			return 0
		}
			
		draw_label(text_get("templateeditoritem") + ":", dx, dy)
		draw_texture_picker(temp_edit.item_index, res.item_sheet_texture, null, dx, dy + 22, dw, dh - 65, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item_scroll, action_lib_item_index)
		break
		
	case "spblock":
		draw_label(text_get("templateeditorblock") + ":", dx, dy)
		sortlist_draw(tab.spblock_list, dx, dy + 22, dw, dh - 90, temp_edit.char_model)
		break
		
	case "bodypart":
		draw_label(text_get("templateeditormodel") + ":", dx, dy)
		sortlist_draw(tab.bodypart_char_list, dx, dy + 22, dw, dh - 116, temp_edit.char_model)
		//draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dy + dh - 65, dw, 24, temp_edit.char_bodypart, text_get(temp_edit.char_model.part_name[temp_edit.char_bodypart]), action_lib_char_bodypart) TODO
		break
		
	case "particles":
		tab_template_editor_particles()
		return 0
	
	default:
		tab_close(tab)
		break
}

dy += dh - 32
if (draw_button_normal("templateeditorok", dx + floor(dw / 2) - 50, dy, 100, 32))
	tab_close(tab)
