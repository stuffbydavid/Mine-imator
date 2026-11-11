/// @desc Draws block or model state controls and returns their required height.
/// @arg asset
/// @arg states
/// @arg picker
/// @arg script
/// @arg x
/// @arg y
/// @arg width
/// @arg [armor]

function draw_state_settings(asset, states, picker, script, xx, yy, wid, armor = false)
{
	var isblock, kind, starty;
	isblock = (asset.object_index = obj_block)
	if (isblock)
		kind = "block"
	else
		kind = "model"

	starty = yy

	menu_filter = picker.search_tbx.text
	menu_filter_normal = minecraft_asset_get_name(kind, asset.name)

	// Align state captions
	draw_set_font(font_label)
	for (var i = 0; i < array_length(states); i += 2)
	{
		var state = states[i];
		if (armor && array_contains(armor_parts, state))
		{
			// Combine armor part variants into a single field
			if (state = "helmet")
				content_capwid = max(content_capwid, text_caption_width("bench/armor_variant"))

			continue
		}

		content_capwid = max(content_capwid, string_width(minecraft_asset_get_name(kind + "/state", state)) + 8)
	}

	menu_model_current = null
	menu_block_current = null

	// Boolean states share rows of two checkboxes
	var columnwidth, index, oldwidth, rowheight;
	rowheight = ui_small_height + 8
	columnwidth = (wid - 8) / 2
	index = 0
	oldwidth = dw
	dw = columnwidth
	
	for (var i = 0; i < array_length(states); i += 2)
	{
		if (states[i + 1] != "true" && states[i + 1] != "false")
			continue

		var state = states[i];
		if (isblock)
		{
			menu_block_current = asset
			menu_block_state_current = asset.states_map[?state]
		}
		else
		{
			menu_model_current = asset
			menu_model_state_current = asset.states_map[?state]
		}

		if (draw_checkbox(kind + "/state/" + state, xx + (index mod 2) * (columnwidth + 8), yy + (index div 2) * rowheight, states[i + 1] = "true", null))
		{
			if (isblock)
				menu_block_state = menu_block_state_current
			else
				menu_model_state = menu_model_state_current

			script_execute(script, states[i + 1] = "true" ? "false" : "true")
		}
		index++
	}
	
	dw = oldwidth
	yy += ceil(index / 2) * rowheight

	// Other states use menus
	for (var i = 0; i < array_length(states); i += 2)
	{
		if (states[i + 1] = "true" || states[i + 1] = "false")
			continue

		var state = states[i];
		if (armor && array_contains(armor_parts, state))
		{
			// Combine armor part variants into a single field
			if (state != "helmet")
				continue

			var variant, text;
			variant = state_vars_get_value(states, "helmet")
			for (var p = 1; p < array_length(armor_parts); p++)
				if (state_vars_get_value(states, armor_parts[p]) != variant)
					variant = "multiple"

			menu_model_current = null
			menu_model_state_current = asset.states_map[?"helmet"]
			menu_model_armor_variant = true
			
			if (variant = "multiple")
				text = text_get("list/multiple")
			else
				text = minecraft_asset_get_name("model/state/value", variant)
			
			if (!draw_button_menu("bench/armor_variant", e_menu.LIST, xx, yy, wid, 24, variant, text, script, false, null, null, "", c_white, 1, content_capwid))
				menu_model_armor_variant = false
		}
		else
		{
			if (isblock)
			{
				menu_block_current = asset
				menu_block_state_current = asset.states_map[?state]
			}
			else
			{
				menu_model_current = asset
				menu_model_state_current = asset.states_map[?state]
			}

			draw_button_menu(state, e_menu.LIST, xx, yy, wid, 24, states[i + 1], minecraft_asset_get_name(kind + "/state/value", states[i + 1]), script, false, null, null, "", c_white, 1, content_capwid)
		}
		
		yy += 32
	}

	menu_model_current = null
	menu_block_current = null
	menu_filter = ""
	menu_filter_normal = ""

	return yy - starty
}
