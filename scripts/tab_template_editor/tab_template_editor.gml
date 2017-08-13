/// tab_template_editor()

if (!instance_exists(temp_edit))
{
	tab_close(tab)
	return 0
}

switch (temp_edit.type)
{
	case "char":
	{
		draw_label(text_get("templateeditorcharmodel") + ":", dx, dy)
		sortlist_draw(tab.char_list, dx, dy + 22, dw, dh - 90, temp_edit.char_model)
		break
	}
	
	case "block":
	{
		// Block
		var statesh = 32 * ds_map_size(temp_edit.block_state_map);
		draw_label(text_get("templateeditorblock") + ":", dx, dy)
		sortlist_draw(tab.block_list, dx, dy + 22, dw, dh - 92 - statesh, temp_edit.block_name)
		
		// States
		var capwid, block, state, dyy;
		block = mc_version.block_name_map[?temp_edit.block_name]
		state = ds_map_find_first(temp_edit.block_state_map)
		capwid = 0
		while (!is_undefined(state))
		{
			capwid = max(capwid, string_width(block_get_name(state, "blockstate") + ":") + 20)
			state = ds_map_find_next(temp_edit.block_state_map, state)
		}
			
		state = ds_map_find_first(temp_edit.block_state_map)
		statesh = 32 * ds_map_size(temp_edit.block_state_map)
		dyy = dy + dh - 42 - statesh
		while (!is_undefined(state))
		{
			menu_block_current = block
			menu_block_state_current = block.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.block_state_map[?state], block_get_name(temp_edit.block_state_map[?state], "blockstatevalue"), action_lib_block_state, null, null, capwid, text_get("templateeditorblockstatetip"))
			state = ds_map_find_next(temp_edit.block_state_map, state)
			dyy += 24 + 8
		}
		menu_block_current = null
		
		break
	}
	
	case "item":
	{
		var res = temp_edit.item_tex;
		if (!res.ready)
			res = res_def
		
		if (res.item_sheet_texture = null)
		{
			tab_close(tab)
			return 0
		}
			
		draw_label(text_get("templateeditoritem") + ":", dx, dy)
		
		var slots = test(res.type = "pack", ds_list_size(mc_version.item_texture_list), res.item_sheet_size[X] * res.item_sheet_size[Y]);
		draw_texture_picker(temp_edit.item_slot, res.item_sheet_texture, dx, dy + 22, dw, dh - 65, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item_scroll, action_lib_item_slot)
		break
	}
	
	case "spblock":
	{
		draw_label(text_get("templateeditorblock") + ":", dx, dy)
		sortlist_draw(tab.spblock_list, dx, dy + 22, dw, dh - 90, temp_edit.char_model)
		break
	}
	
	case "bodypart":
	{
		draw_label(text_get("templateeditormodel") + ":", dx, dy)
		sortlist_draw(tab.bodypart_char_list, dx, dy + 22, dw, dh - 116, temp_edit.char_model)
		//draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dy + dh - 65, dw, 24, temp_edit.char_bodypart, text_get(temp_edit.char_model.part_name[temp_edit.char_bodypart]), action_lib_char_bodypart) TODO
		break
	}
	
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
