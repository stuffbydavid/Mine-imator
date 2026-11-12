/// @desc Draws a prepared state value grid and returns its height.
/// @arg picker
/// @arg element
/// @arg script
/// @arg x
/// @arg y
/// @arg width
/// @arg resource

function draw_state_settings_picker(picker, element, script, xx, yy, wid, res)
{
	var asset, pickerstate, selected, tip, values, hei, scroll, pickerarmor, kind;
	asset = state_settings_asset
	pickerstate = asset.states_map[?element[1]]
	selected = element[2]
	tip = element[3]
	values = element[4]
	hei = element[5]
	scroll = picker.scroll
	pickerarmor = (asset.name = "armor" && array_contains(armor_parts, pickerstate.name))
	
	if (asset.object_index = obj_block)
		kind = "block"
	else
		kind = "model"

	if (picker.last_state != pickerstate)
	{
		picker.last_state = pickerstate
		scroll.value = 0
		scroll.value_goal = 0
		picker.tip_slot = -1
	}

	if (content_mouseon && app_mouse_box(xx, yy, wid, hei))
		window_scroll_focus = string(scroll)

	if (xx + wid < content_x || xx > content_x + content_width || yy + hei < content_y || yy > content_y + content_height || wid <= 2)
		return hei + 8

	// Fit columns and reserve space for the scrollbar
	var slotsize, count, viewhei, columns, gridwid, gridx, contenthei, maxscroll, first, last;
	slotsize = 68
	count = array_length(values)
	viewhei = hei - 2
	gridwid = wid - 2
	columns = max(1, floor(gridwid / slotsize))
	
	scroll.needed = (ceil(count / columns) * slotsize > viewhei)
	if (scroll.needed)
	{
		gridwid = max(1, gridwid - 14)
		columns = max(1, floor(gridwid / slotsize))
	}

	gridx = xx + 1 + max(0, floor((gridwid - columns * slotsize) / 2))
	contenthei = ceil(count / columns) * slotsize

	// Clamp scrolling and find the visible images
	maxscroll = max(0, contenthei - viewhei)
	scroll.value = clamp(scroll.value, 0, maxscroll)
	scroll.value_goal = clamp(scroll.value_goal, 0, maxscroll)
	first = clamp(floor(scroll.value / slotsize) * columns, 0, count)
	last = clamp(ceil((scroll.value + viewhei) / slotsize) * columns, 0, count)

	// Generate only the visible images before drawing the clipped grid
	var textures, prevalpha, prevcolor, prevfont;
	textures = []
	prevalpha = draw_get_alpha()
	prevcolor = draw_get_color()
	prevfont = draw_get_font()
	
	res = res_eval(res)
	for (var i = first; i < last; i++)
	{
		var vars = array_copy_1d(state_settings_states);
		if (pickerarmor)
		{
			for (var p = 0; p < array_length(armor_parts); p++)
				state_vars_set_value(vars, armor_parts[p], values[i])
		}
		else
			state_vars_set_value(vars, pickerstate.name, values[i])

		var tex;
		with (res)
			tex = res_get_asset_picker_texture(asset, vars)

		textures[i - first] = tex
	}
	
	draw_set_alpha(prevalpha)
	draw_set_color(prevcolor)
	draw_set_font(prevfont)

	draw_box(xx + 1, yy + 1, wid - 2, hei - 2, false, c_input_background)
	draw_outline(xx, yy, wid, hei, 1, window_focus = string(scroll) ? c_accent : c_border, window_focus = string(scroll) ? 1 : a_border, true)

	// Preserve the surrounding clip
	var clipactive, clipx, clipy, clipwid, cliphei;
	clipactive = shader_clip_active
	if (clipactive)
	{
		clipx = shader_clip_x
		clipy = shader_clip_y
		clipwid = shader_clip_width
		cliphei = shader_clip_height
	}
	
	clip_begin(xx + 1, yy + 1, gridwid, hei - 2)

	var mouseon, previoustip;
	mouseon = content_mouseon && window_busy = "" && app_mouse_box(xx + 1, yy + 1, gridwid, hei - 2)
	previoustip = picker.tip_slot
	picker.tip_slot = -1
	
	shader_texture_filter_linear = false
	
	draw_texture_start()
	
	for (var i = first; i < last; i++)
	{
		var tx, ty, hovered, value, tex;
		tx = gridx + (i mod columns) * slotsize
		ty = floor(yy + 1 + (i div columns) * slotsize - scroll.value)
		hovered = mouseon && app_mouse_box(tx, ty, slotsize, slotsize)
		value = values[i]
		
		if (selected = value || (hovered && mouse_left))
		{
			draw_texture_done()
			draw_box(tx, ty, slotsize, slotsize, false, c_accent_overlay, a_accent_overlay)
			
			if (hovered && mouse_left)
				draw_box_hover(tx, ty, slotsize, slotsize, 1)
			
			draw_texture_start()
		}
		else if (hovered)
		{
			draw_texture_done()
			draw_box(tx, ty, slotsize, slotsize, false, c_overlay, a_overlay)
			draw_texture_start()
		}

		tex = textures[i - first]
		if (tex != null)
			draw_texture_part(tex, tx + 2, ty + 2, 0, 0, 64, 64)
		
		if (!hovered)
			continue

		mouse_cursor = cr_handpoint
		
		if (previoustip != i)
			picker.tip_time = current_time
		
		picker.tip_slot = i
		
		if (current_time - picker.tip_time >= 250)
		{
			var text = minecraft_asset_get_name(kind + "/state/value", value);
			if (tip != "")
				text += "\n" + text_get(tip)

			tip_set(text, tx, ty, slotsize, slotsize)
		}

		if (mouse_left_released)
		{
			draw_texture_done()
			
			if (asset.object_index = obj_block)
				menu_block_state = pickerstate
			else
				menu_model_state = pickerstate

			menu_model_armor_variant = pickerarmor
			
			script_execute(script, value)
			
			window_focus = string(scroll)
			app_mouse_clear()
			
			draw_texture_start()
		}
	}
	
	draw_texture_done()

	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)

	scroll.snap_value = 0
	scroll.wheel_speed = slotsize
	
	scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 12, yy + 1, hei - 2, contenthei)

	return hei + 8
}
