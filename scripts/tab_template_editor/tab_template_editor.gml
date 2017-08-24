/// tab_template_editor()

if (!instance_exists(temp_edit))
{
	tab_close(tab)
	return 0
}

switch (temp_edit.type)
{
	case "char":
	case "spblock":
	case "bodypart":
	{
		var labeltext, list, capwid;
		if (temp_edit.type = "char")
		{
			labeltext = text_get("templateeditormodel")
			list = tab.char_list
			capwid  = 0
		}
		else if (temp_edit.type = "spblock")
		{
			labeltext = text_get("templateeditorblock")
			list = tab.special_block_list
			capwid  = 0
		}
		else if (temp_edit.type = "bodypart")
		{
			labeltext = text_get("templateeditormodel")
			list = tab.bodypart_model_list
			capwid  = text_caption_width("templateeditorbodypart")
		}
			
		// Model
		var statesh = 32 * ds_map_size(temp_edit.model_state_map) + test(temp_edit.type = "bodypart", 32, 0);
		draw_label(labeltext + ":", dx, dy)
		sortlist_draw(list, dx, dy + 22, dw, dh - 92 - statesh, temp_edit.model_name)
			
		// States
		var model, state, dyy;
		model = mc_assets.model_name_map[?temp_edit.model_name]
		state = ds_map_find_first(temp_edit.model_state_map)
		while (!is_undefined(state))
		{
			capwid = max(capwid, string_width(minecraft_asset_get_name("modelstate", state) + ":") + 20)
			state = ds_map_find_next(temp_edit.model_state_map, state)
		}
			
		state = ds_map_find_first(temp_edit.model_state_map)
		statesh = 32 * ds_map_size(temp_edit.model_state_map) + test(temp_edit.type = "bodypart", 32, 0)
		dyy = dy + dh - 42 - statesh
		while (!is_undefined(state))
		{
			menu_model_current = model
			menu_model_state_current = model.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_state_map[?state], minecraft_asset_get_name("modelstatevalue", temp_edit.model_state_map[?state]), test(temp_edit.type = "bodypart", action_lib_bodypart_model_state, action_lib_model_state), null, null, capwid, text_get("templateeditormodelstatetip"))
			state = ds_map_find_next(temp_edit.model_state_map, state)
			dyy += 24 + 8
		}
		menu_model_current = null
			
		// Bodypart
		if (temp_edit.type = "bodypart")
			draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_part_name, minecraft_asset_get_name("modelpart", temp_edit.model_part_name), action_lib_model_part_name, null, null, capwid)
		
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
		block = mc_assets.block_name_map[?temp_edit.block_name]
		state = ds_map_find_first(temp_edit.block_state_map)
		capwid = 0
		while (!is_undefined(state))
		{
			capwid = max(capwid, string_width(minecraft_asset_get_name("blockstate", state) + ":") + 20)
			state = ds_map_find_next(temp_edit.block_state_map, state)
		}
			
		state = ds_map_find_first(temp_edit.block_state_map)
		statesh = 32 * ds_map_size(temp_edit.block_state_map)
		dyy = dy + dh - 42 - statesh
		while (!is_undefined(state))
		{
			menu_block_current = block
			menu_block_state_current = block.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.block_state_map[?state], minecraft_asset_get_name("blockstatevalue", temp_edit.block_state_map[?state]), action_lib_block_state, null, null, capwid, text_get("templateeditorblockstatetip"))
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
		
		var slots = test(res.type = "pack", ds_list_size(mc_assets.item_texture_list), res.item_sheet_size[X] * res.item_sheet_size[Y]);
		draw_texture_picker(temp_edit.item_slot, res.item_sheet_texture, dx, dy + 22, dw, dh - 65, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item_scroll, action_lib_item_slot)
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
