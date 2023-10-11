/// tab_template_editor()

function tab_template_editor()
{
	if (!instance_exists(temp_edit))
	{
		tab_close(tab)
		return 0
	}
	
	// Modify draw area
	if (temp_edit.type != e_temp_type.PARTICLE_SPAWNER)
		dh -= 28
	
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
			var statelen, statesh, menus, checkboxes;
			statelen = array_length(temp_edit.model_state)
			statesh = ((temp_edit.type = e_temp_type.BODYPART) ? 32 : 0)
			menus = 0
			checkboxes = 0
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.model_state[i + 1] != "true" && temp_edit.model_state[i + 1] != "false")
					menus++
				else
					checkboxes++
			}
			
			statesh += (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			sortlist_draw(list, dx, dy, dw, dh - statesh, temp_edit.model_name, false)
			menu_filter = list.search_tbx.text
			menu_filter_normal = sortlist_column_get(list, temp_edit.model_name, 0)
			
			// Update states in case model was updated
			statelen = array_length(temp_edit.model_state)
			statesh = ((temp_edit.type = e_temp_type.BODYPART) ? 32 : 0)
			menus = 0
			checkboxes = 0
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.model_state[i + 1] != "true" && temp_edit.model_state[i + 1] != "false")
					menus++
				else
					checkboxes++
			}
			
			statesh += (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			
			// States
			var model = mc_assets.model_name_map[?temp_edit.model_name];
			
			draw_set_font(font_label)
			for (var i = 0; i < statelen; i += 2)
			{
				var state = temp_edit.model_state[i];
				capwid = max(capwid, string_width(minecraft_asset_get_name("modelstate", state)) + 8)
			}
			
			var dyy = (dy + dh - statesh) + 8;
			
			// Checkboxes
			dy = dyy
			tab_set_collumns(true, 2)
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.model_state[i + 1] != "true" && temp_edit.model_state[i + 1] != "false")
					continue
				
				var state = temp_edit.model_state[i];
				menu_model_current = model
				menu_model_state_current = model.states_map[?state]
				
				tab_control(ui_small_height)
				
				if (draw_checkbox("modelstate" + state, dx, dy, temp_edit.model_state[i + 1] = "true", null))
				{
					menu_model_state = menu_model_state_current
					
					var script = (temp_edit.type = e_temp_type.BODYPART) ? action_lib_bodypart_model_state : action_lib_model_state;
					
					if (temp_edit.model_state[i + 1] = "true")
						script_execute(script, "false")
					else
						script_execute(script, "true")
				}
				
				tab_next()
			}
			
			tab_set_collumns(false)
			dyy = dy
			
			// Menus
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.model_state[i + 1] = "true" || temp_edit.model_state[i + 1] = "false")
					continue
				
				var state = temp_edit.model_state[i];
				menu_model_current = model
				menu_model_state_current = model.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_state[i + 1], minecraft_asset_get_name("modelstatevalue", temp_edit.model_state[i + 1]), (temp_edit.type = e_temp_type.BODYPART) ? action_lib_bodypart_model_state : action_lib_model_state, false, null, null, "", c_white, 1, capwid)
				dyy += 32
			}
			menu_model_current = null
			menu_filter = ""
			menu_filter_normal = ""
			
			// Bodypart
			if (temp_edit.type = e_temp_type.BODYPART)
				draw_button_menu("templateeditorbodypart", e_menu.LIST, dx, dyy, dw, 24, temp_edit.model_part_name, minecraft_asset_get_name("modelpart", temp_edit.model_part_name), action_lib_model_part_name, false, null, null, "", c_white, 1, capwid)
			
			if (content_mouseon)
				window_scroll_focus = string(list.scroll)
			
			break
		}
		
		case e_temp_type.BLOCK:
		{
			// Block
			var statelen, statesh, menus, checkboxes;
			statelen = array_length(temp_edit.block_state)
			menus = 0
			checkboxes = 0
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.block_state[i + 1] != "true" && temp_edit.block_state[i + 1] != "false")
					menus++
				else
					checkboxes++
			}
			
			statesh = (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			
			sortlist_draw(tab.block_list, dx, dy, dw, dh - statesh, temp_edit.block_name, false)
			menu_filter = tab.block_list.search_tbx.text
			menu_filter_normal = sortlist_column_get(tab.block_list, temp_edit.block_name, 0)
			
			// States
			var block;
			block = mc_assets.block_name_map[?temp_edit.block_name]
			statelen = array_length(temp_edit.block_state)
			menus = 0
			checkboxes = 0
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.block_state[i + 1] != "true" && temp_edit.block_state[i + 1] != "false")
					menus++
				else
					checkboxes++
			}
			
			statesh = (32 * menus) + ((ui_small_height + 8) * ceil(checkboxes/2))
			capwid = 0
			
			draw_set_font(font_label)
			for (var i = 0; i < statelen; i += 2)
			{
				var state = temp_edit.block_state[i];
				capwid = max(capwid, string_width(minecraft_asset_get_name("blockstate", state)) + 8)
			}
			
			var dyy = (dy + dh - statesh) + 8;
			
			// Checkboxes
			dy = dyy
			tab_set_collumns(true, 2)
			
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.block_state[i + 1] != "true" && temp_edit.block_state[i + 1] != "false")
					continue
				
				var state = temp_edit.block_state[i];
				menu_block_current = block
				menu_block_state_current = block.states_map[?state]
				
				tab_control(ui_small_height)
				
				if (draw_checkbox("blockstate" + state, dx, dy, temp_edit.block_state[i + 1] = "true", null))
				{
					menu_block_state = menu_block_state_current
					
					if (temp_edit.block_state[i + 1] = "true")
						script_execute(action_lib_block_state, "false")
					else
						script_execute(action_lib_block_state, "true")
				}
				
				tab_next()
			}
			
			tab_set_collumns(false)
			dyy = dy
			
			// Menus
			for (var i = 0; i < statelen; i += 2)
			{
				if (temp_edit.block_state[i + 1] = "true" || temp_edit.block_state[i + 1] = "false")
					continue
				
				var state = temp_edit.block_state[i];
				menu_block_current = block
				menu_block_state_current = block.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dyy, dw, 24, temp_edit.block_state[i + 1], minecraft_asset_get_name("blockstatevalue", temp_edit.block_state[i + 1]), action_lib_block_state, false, null, null, "", c_white, 1, capwid)
				dyy += 32
			}
			menu_block_current = null
			menu_filter = ""
			menu_filter_normal = ""
			
			if (content_mouseon)
				window_scroll_focus = string(tab.block_list.scroll)
			
			break
		}
		
		case e_temp_type.ITEM:
		{
			var res = temp_edit.item_tex;
			if (!res_is_ready(res))
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
}
