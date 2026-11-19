/// @desc Prepares state settings elements and their total height.
/// @arg asset
/// @arg build
/// @arg states
/// @arg width
/// @arg [grid]
/// @arg [maxrows]

function state_settings_load(asset, build, states, wid, grid = true, maxrows = 3)
{
	var elements, menus, checkboxes, picker, hei, capwid, pickerstate, usestates, armor, kind, oldfont;
	elements = []
	menus = []
	checkboxes = []
	picker = null
	hei = 0
	capwid = 0
	states = array_copy_1d(states)
	pickerstate = null
	usestates = []
	armor = (asset.name = "armor")
	
	if (asset.object_index = obj_block)
		kind = "block"
	else
		kind = "model"

	// Find the first configured picker state
	if (asset.states_map != null)
	{
		for (var i = 0; i < ds_list_size(mc_assets.state_picker_list); i++)
		{
			var state = mc_assets.state_picker_list[|i];
			if (armor && state = "variant")
				state = "helmet"

			if (ds_map_exists(asset.states_map, state))
			{
				pickerstate = asset.states_map[?state]
				break
			}
		}
	}

	// Include a configured state even when it uses the implicit default value
	if (pickerstate != null && state_vars_get_value(states, pickerstate.name) = null)
		state_vars_set_value(states, pickerstate.name, pickerstate.value_name[0])

	// Identify states controlled by right click
	if (build)
	{
		var block = mc_assets.block_name_map[?asset.name];
		if (!is_undefined(block) && block.build_map != null)
		{
			var use = block.build_map[?"use"];
			
			if (is_string(use))
				array_add(usestates, use)
			else if (ds_list_valid(use))
			{
				for (var i = 0; i < ds_list_size(use); i++)
				{
					var vars = string_get_state_vars(use[|i]);
					for (var v = 0; v < array_length(vars); v += 2)
						array_add(usestates, vars[v])
				}
			}
			
			if (!is_undefined(block.build_map[?"use_book_slot"]))
				array_add(usestates, "slot_0_occupied")
		}
	}

	oldfont = draw_get_font()
	draw_set_font(font_label)
	
	// Elements store their type, state name, current value and tooltip
	for (var i = 0; i < array_length(states); i += 2)
	{
		var state, value, type, tip, combined, ispicker, element;
		state = states[i]
		value = states[i + 1]
		if (asset.states_map = null || !ds_map_exists(asset.states_map, state))
			continue

		// Hide build tool-provided states
		if (build && (state = "axis" || state = "facing" || state = "half" || state = "part" || state = "shape"))
			continue
		
		// Hide armor parts
		if (armor && state != "helmet" && array_contains(armor_parts, state))
			continue

		combined = (armor && state = "helmet")
		ispicker = (pickerstate != null && state = pickerstate.name)
		tip = array_contains(usestates, state) ? "build_tool/use_tip" : ""
		
		if (combined)
		{
			for (var p = 1; p < array_length(armor_parts); p++)
				if (state_vars_get_value(states, armor_parts[p]) != value)
				{
					value = "multiple"
					break
				}
		}

		if (ispicker && grid)
			type = "picker"
		else if (combined)
			type = "armor"
		else if (!ispicker && (value = "true" || value = "false"))
			type = "checkbox"
		else
			type = "menu"
		
		element = [ type, state, value, tip ]

		if (type = "picker")
		{
			// Grids also store the visible values and their height
			var values, columns, pickerhei, slotsize;
			slotsize = 68
			values = pickerstate.value_name
			if (combined)
			{
				values = []
				for (var v = 0; v < pickerstate.value_amount; v++)
					if (pickerstate.value_name[v] != "none" && pickerstate.value_name[v] != "turtle_scute")
						array_add(values, pickerstate.value_name[v])
			}

			columns = max(1, floor((wid - 2) / slotsize))
			if (ceil(array_length(values) / columns) > maxrows)
				columns = max(1, floor((wid - 16) / slotsize))

			pickerhei = min(maxrows, ceil(array_length(values) / columns)) * slotsize + 2
			
			array_add(element, values, false)
			array_add(element, pickerhei)
			
			hei += pickerhei + 8
		}
		else
		{
			if (type = "armor")
				capwid = max(capwid, text_caption_width("bench/armor_variant"))
			else
				capwid = max(capwid, string_width(minecraft_asset_get_name(kind + "/state", state)) + 8 + (tip != "" ? 24 : 0))

			if (type != "checkbox")
				hei += 32
		}

		if (ispicker)
			picker = element
		else if (type = "checkbox")
			array_add(checkboxes, element, false)
		else
			array_add(menus, element, false)
	}
	
	draw_set_font(oldfont)

	// Keep the selected picker first and checkboxes last
	if (picker != null)
		array_add(elements, picker, false)
	
	array_add(elements, menus)
	array_add(elements, checkboxes)
	
	hei += ceil(array_length(checkboxes) / 2) * (ui_small_height + 8)

	state_settings_elements = elements
	state_settings_height = hei
	state_settings_capwid = capwid
	state_settings_asset = asset
	state_settings_states = states
}
