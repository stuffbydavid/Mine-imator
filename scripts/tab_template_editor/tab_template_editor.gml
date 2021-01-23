/// tab_template_editor()

if (!instance_exists(temp_edit))
{
	tab_close(tab)
	return 0
}

// Modify draw area
if (temp_edit.type != e_temp_type.PARTICLE_SPAWNER)
	dh -= (36 + 34)

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
			capwid = 0
		}
		else if (temp_edit.type = e_temp_type.SPECIAL_BLOCK)
		{
			labeltext = text_get("templateeditorblock")
			list = tab.special_block_list
			capwid = 0
		}
		else if (temp_edit.type = e_temp_type.BODYPART)
		{
			labeltext = text_get("templateeditormodel")
			list = tab.bodypart_model_list
			capwid = text_caption_width("templateeditorbodypart")
		}
		
		// Model
		var statelen, statesh;
		statelen = array_length_1d(temp_edit.model_state)
		statesh = 52 * (statelen / 2) + ((temp_edit.type = e_temp_type.BODYPART) ? 52 : 0);
		sortlist_draw(list, dx, dy, dw, dh - statesh, temp_edit.model_name, false)
		
		// States
		var model = mc_assets.model_name_map[?temp_edit.model_name];
		statelen = array_length_1d(temp_edit.model_state)
		statesh = 52 * (statelen / 2) + ((temp_edit.type = e_temp_type.BODYPART) ? 52 : 0)
		
		var dyy = (dy + dh - statesh) + 8;
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.model_state[i];
			menu_model_current = model
			menu_model_state_current = model.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", temp_edit.model_state[i + 1]), (temp_edit.type = e_temp_type.BODYPART) ? action_lib_bodypart_model_state : action_lib_model_state)
			dyy += 52
		}
		menu_model_current = null
		
		// Bodypart
		if (temp_edit.type = e_temp_type.BODYPART)
			draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_part_name, minecraft_asset_get_name("modelpart", temp_edit.model_part_name), action_lib_model_part_name)
		
		if (content_mouseon)
			window_scroll_focus = string(list.scroll)
		
		break
	}
	
	case e_temp_type.BLOCK:
	{
		// Block
		var statelen, statesh;
		statelen = array_length_1d(temp_edit.block_state)
		statesh = 52 * (statelen / 2)
		sortlist_draw(tab.block_list, dx, dy, dw, dh - statesh, temp_edit.block_name, false)
		
		// States
		var block;
		block = mc_assets.block_name_map[?temp_edit.block_name]
		statelen = array_length_1d(temp_edit.block_state)
		statesh = 52 * (statelen / 2)
		
		var dyy = (dy + dh - statesh) + 8;
		for (var i = 0; i < statelen; i += 2)
		{
			var state = temp_edit.block_state[i];
			menu_block_current = block
			menu_block_state_current = block.states_map[?state]
			draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 28, temp_edit.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", temp_edit.block_state[i + 1]), action_lib_block_state)
			dyy += 52
		}
		menu_block_current = null
		
		if (content_mouseon)
			window_scroll_focus = string(tab.block_list.scroll)
		
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
		
		var slots = ((res.type = e_res_type.PACK) ? ds_list_size(mc_assets.item_texture_list) : (res.item_sheet_size[X] * res.item_sheet_size[Y]));
		draw_texture_picker(temp_edit.item_slot, res.item_sheet_texture, dx, dy, dw, dh, slots, res.item_sheet_size[X], res.item_sheet_size[Y], tab.item_scroll, action_lib_item_slot)
		
		if (content_mouseon)
			window_scroll_focus = string(tab.item_scroll)
		
		break
	}
	
	case e_temp_type.PARTICLE_SPAWNER:
		tab_template_editor_particles()
		return 0
	
	default:
		tab_close(tab)
		break
}

dy += dh + 8
if (draw_button_label("templateeditordone", floor(dx + dw/2), dy, null, null, e_button.PRIMARY, null, e_anchor.CENTER))
	tab_close(tab)
