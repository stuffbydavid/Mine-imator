/// @desc Draws the prepared state elements and returns their height.
/// @arg filter
/// @arg script
/// @arg x
/// @arg y
/// @arg width
/// @arg resource
/// @arg picker

function draw_state_settings(filter, script, xx, yy, wid, res, picker)
{
	var isblock, kind, index, rowhei, columnwid, oldwid;
	isblock = (state_settings_asset.object_index = obj_block)
	if (isblock)
		kind = "block"
	else
		kind = "model"

	index = 0
	rowhei = ui_small_height + 8
	columnwid = (wid - 8) / 2
	oldwid = dw
	
	content_capwid = max(content_capwid, state_settings_capwid)
	
	menu_filter = filter
	menu_filter_normal = minecraft_asset_get_name(kind, state_settings_asset.name)
	menu_model_current = null
	menu_block_current = null

	for (var i = 0; i < array_length(state_settings_elements); i++)
	{
		var el, type, name, value, tip, state;
		el = state_settings_elements[i]
		type = el[0]
		name = el[1]
		value = el[2]
		tip = el[3]
		
		if (type = "picker")
		{
			yy += draw_state_settings_picker(picker, el, script, xx, yy, wid, res)
			continue
		}

		state = state_settings_asset.states_map[?name]
		if (type = "checkbox")
		{
			dw = columnwid
			
			if (draw_checkbox(kind + "/state/" + name, xx + (index mod 2) * (columnwid + 8), yy + (index div 2) * rowhei, value = "true", null, tip))
			{
				if (isblock)
					menu_block_state = state
				else
					menu_model_state = state

				menu_model_armor_variant = false
				script_execute(script, value = "true" ? "false" : "true")
			}
			
			index++
			
			continue
		}

		if (type = "armor")
		{
			menu_model_current = null
			menu_model_state_current = state
			menu_model_armor_variant = true
			
			var text;
			if (value = "multiple")
				text = text_get("list/multiple")
			else
				text = minecraft_asset_get_name("model/state/value", value)

			if (!draw_button_menu("bench/armor_variant", e_menu.LIST, xx, yy, wid, 24, value, text, script, false, null, null, "", c_white, 1, content_capwid))
				menu_model_armor_variant = false
		}
		else
		{
			menu_model_armor_variant = false
			
			if (isblock)
			{
				menu_block_current = state_settings_asset
				menu_block_state_current = state
			}
			else
			{
				menu_model_current = state_settings_asset
				menu_model_state_current = state
			}

			draw_button_menu(name, e_menu.LIST, xx, yy, wid, 24, value, minecraft_asset_get_name(kind + "/state/value", value), script, false, null, null, "", c_white, 1, content_capwid, tip)
		}
		
		yy += 32
	}

	dw = oldwid
	
	menu_model_current = null
	menu_block_current = null
	menu_filter = ""
	menu_filter_normal = ""

	return state_settings_height
}
