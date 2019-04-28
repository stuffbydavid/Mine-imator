/// tab_template_editor()

if (!instance_exists(temp_edit))
{
	tab_close(tab)
	return 0
}

switch (temp_edit.type)
{
	case e_temp_type.CHARACTER:
	case e_temp_type.SPECIAL_BLOCK:
	case e_temp_type.BODYPART:
	{
		var labeltext, list, capwid;
		if (temp_edit.type = e_temp_type.CHARACTER)
		{
			labeltext = text_get("templateeditormodel")
			list = tab.char_list
			capwid  = 0
		}
		else if (temp_edit.type = e_temp_type.SPECIAL_BLOCK)
		{
			labeltext = text_get("templateeditorblock")
			list = tab.special_block_list
			capwid  = 0
		}
		else if (temp_edit.type = e_temp_type.BODYPART)
		{
			labeltext = text_get("templateeditormodel")
			list = tab.bodypart_model_list
			capwid  = text_caption_width("templateeditorbodypart")
		}
			
		// Model
		var statelen, statesh;
		statelen = array_length_1d(temp_edit.model_state)
		statesh = 32 * (statelen / 2) + ((temp_edit.type = e_temp_type.BODYPART) ? 32 : 0);
		draw_label(labeltext + ":", dx, dy)
		sortlist_draw(list, dx, dy + 22, dw, dh - 92 - statesh, temp_edit.model_name)
			
		// States
		var model = mc_assets.model_name_map[?temp_edit.model_name];
		statelen = array_length_1d(temp_edit.model_state)
		statesh = 32 * (statelen / 2) + ((temp_edit.type = e_temp_type.BODYPART) ? 32 : 0)
		
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.model_state[i];
			capwid = max(capwid, string_width(minecraft_asset_get_name("modelstate", state) + ":") + 20)
		}
			
		var dyy = dy + dh - 42 - statesh;
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.model_state[i];
			menu_model_current = model
			menu_model_state_current = model.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", temp_edit.model_state[i + 1]), ((temp_edit.type = e_temp_type.BODYPART) ? action_lib_bodypart_model_state : action_lib_model_state), null, null, capwid, text_get("templateeditormodelstatetip"))
			dyy += 24 + 8
		}
		menu_model_current = null
			
		// Bodypart
		if (temp_edit.type = e_temp_type.BODYPART)
			draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_part_name, minecraft_asset_get_name("modelpart", temp_edit.model_part_name), action_lib_model_part_name, null, null, capwid)
		
		break
	}
	
	case e_temp_type.BLOCK:
	{
		// Block
		var statelen, statesh;
		statelen = array_length_1d(temp_edit.block_state)
		statesh = 32 * (statelen / 2)
		draw_label(text_get("templateeditorblock") + ":", dx, dy)
		sortlist_draw(tab.block_list, dx, dy + 22, dw, dh - 92 - statesh, temp_edit.block_name)
		
		// States
		var block, capwid;
		block = mc_assets.block_name_map[?temp_edit.block_name]
		statelen = array_length_1d(temp_edit.block_state)
		statesh = 32 * (statelen / 2)
		capwid = 0
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.block_state[i];
			capwid = max(capwid, string_width(minecraft_asset_get_name("blockstate", state) + ":") + 20)
		}
			
		var dyy = dy + dh - 42 - statesh;
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.block_state[i];
			menu_block_current = block
			menu_block_state_current = block.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", temp_edit.block_state[i + 1]), action_lib_block_state, null, null, capwid, text_get("templateeditorblockstatetip"))
			dyy += 24 + 8
		}
		menu_block_current = null
		
		break
	}
	
	case e_temp_type.ITEM:
	{
		var res = temp_edit.item_tex;
		if (!res.ready)
			res = mc_res
		
		if (res.item_sheet_texture = null)
		{
			tab_close(tab)
			return 0
		}
			
		draw_label(text_get("templateeditoritem") + ":", dx, dy)
		
		var slots = ((res.type = e_res_type.PACK) ? ds_list_size(mc_assets.item_texture_list) : (res.item_sheet_size[X] * res.item_sheet_size[Y]));
		draw_texture_picker(temp_edit.item_slot, res.item_sheet_texture, dx, dy + 22, dw, dh - 65, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item_scroll, action_lib_item_slot)
		break
	}
	
	case e_temp_type.PARTICLE_SPAWNER:
		tab_template_editor_particles()
		return 0
	
	default:
		tab_close(tab)
		break
}

dy += dh - 32
if (draw_button_normal("templateeditorok", dx + floor(dw / 2) - 50, dy, 100, 32))
	tab_close(tab)
