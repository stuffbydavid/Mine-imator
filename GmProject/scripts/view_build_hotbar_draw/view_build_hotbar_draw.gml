function view_build_hotbar_draw(view)
{
	view.hotbar_x = null
	view.hotbar_mouseon = false
	
	if (view != view_main || !place_build)
		return 0

	if (build_hotbar_hide)
	{
		build_hotbar_hide = false
		return 0
	}

	if (build_hotbar_current = null)
		return 0

	var blocks, amount, slotsize, gap, spacing, padding, xx, yy, wid, hei, res;
	var fullwid, arrowwid, gridx, gridwid, maxscroll, first, last, busy, hoverslot;
	blocks = build_hotbar_current.blocks
	amount = array_length(blocks)

	slotsize = 64
	gap = 4
	spacing = slotsize + gap
	padding = 8
	fullwid = amount * spacing - gap + padding * 2 + 56
	wid = min(fullwid, content_width - 32)
	hei = slotsize + padding * 2
	arrowwid = (fullwid > wid ? 24 : 0)
	gridwid = wid - padding * 2 - 56 - arrowwid * 2
	if (gridwid <= 0 || content_height < hei + 8)
		return 0

	xx = floor(content_x + (content_width - wid) / 2)
	yy = content_y + content_height - hei - 8
	view.hotbar_x = xx
	gridx = xx + padding + 28 + arrowwid
	busy = build_drag_active ? "build/drag" : place_busy
	
	view.hotbar_mouseon = (!build_first_person && (view.mouseon || build_drag_active) && !popup_mouseon && !toast_mouseon &&
		!context_menu_mouseon && !(view_second.show && view_second.mouseon) &&
		app_mouse_box(xx, yy, wid, hei, window_busy) &&
		app_mouse_box(content_x, content_y, content_width, content_height, window_busy))

	// Scroll while holding either arrow and snap in that direction on release
	var dir = 0;
	if (arrowwid > 0 && view.hotbar_mouseon && mouse_left)
	{
		if (app_mouse_box(gridx - arrowwid, yy, arrowwid, hei, busy))
			dir = -1
		else if (app_mouse_box(gridx + gridwid, yy, arrowwid, hei, busy))
			dir = 1
	}

	maxscroll = max(0, amount * spacing - gap - gridwid)
	view.hotbar_offset = clamp(view.hotbar_offset, 0, maxscroll)
	view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
	
	if (dir != 0)
		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal + dir * 8 * delta, 0, maxscroll)
	else if (view.hotbar_scroll_direction != 0)
	{
		if (view.hotbar_scroll_direction > 0)
			view.hotbar_offset_goal = ceil(view.hotbar_offset / spacing) * spacing
		else
			view.hotbar_offset_goal = floor(view.hotbar_offset / spacing) * spacing

		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
	}
	view.hotbar_scroll_direction = dir

	// Handle slot changes before drawing the updated blocks and selection
	hoverslot = -1
	if (view.hotbar_mouseon && app_mouse_box(gridx, yy + padding, gridwid, slotsize, busy))
	{
		var slotx = mouse_x - gridx + round(view.hotbar_offset);
		if (slotx mod spacing < slotsize)
			hoverslot = floor(slotx / spacing)
	}

	if (build_drag_active)
	{
		if (view.hotbar_mouseon && (mouse_x < gridx || mouse_x >= gridx + gridwid))
		{
			build_drag_target = build_hotbar_current
			build_drag_target_slot = (mouse_x < gridx ? 0 : amount)
			build_drag_insert = true
		}
		else if (hoverslot >= 0)
		{
			build_drag_target = build_hotbar_current
			build_drag_target_slot = hoverslot
		}

		if (!mouse_left)
		{
			build_drag_stop()
			blocks = build_hotbar_current.blocks
			busy = place_busy
		}
	}
	else if (hoverslot >= 0)
	{
		if (mouse_left_pressed && !keyboard_check(vk_shift))
			build_drag_start(blocks[hoverslot], blocks[hoverslot][2], build_hotbar_current, hoverslot)

		if (mouse_left_released)
		{
			if (keyboard_check(vk_shift))
				action_build_hotbar_clear(hoverslot)
			else
				action_build_hotbar_select(hoverslot)

			blocks = build_hotbar_current.blocks
		}
	}

	// Refresh the bounds when a side drop inserts a cell
	if (array_length(blocks) != amount)
	{
		fullwid += (array_length(blocks) - amount) * spacing
		amount = array_length(blocks)
		wid = min(fullwid, content_width - 32)
		arrowwid = (fullwid > wid ? 24 : 0)
		gridwid = wid - padding * 2 - 56 - arrowwid * 2
		xx = floor(content_x + (content_width - wid) / 2)
		view.hotbar_x = xx
		gridx = xx + padding + 28 + arrowwid
		maxscroll = max(0, amount * spacing - gap - gridwid)
	}

	// Reveal selections made with the mouse wheel, number keys or block picking
	if (view.hotbar_selected != build_hotbar_current || view.hotbar_slot != build_hotbar_slot)
	{
		if (view.hotbar_selected != build_hotbar_current)
		{
			view.hotbar_offset = 0
			view.hotbar_offset_goal = 0
		}

		if (build_hotbar_slot * spacing < view.hotbar_offset_goal)
			view.hotbar_offset_goal = build_hotbar_slot * spacing
		else if (build_hotbar_slot * spacing + slotsize > view.hotbar_offset_goal + gridwid)
			view.hotbar_offset_goal = ceil((build_hotbar_slot * spacing + slotsize - gridwid) / spacing) * spacing

		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
		view.hotbar_selected = build_hotbar_current
		view.hotbar_slot = build_hotbar_slot
	}

	view.hotbar_offset += (view.hotbar_offset_goal - view.hotbar_offset) / max(1, 4 / delta)
	if (abs(view.hotbar_offset_goal - view.hotbar_offset) < .5)
		view.hotbar_offset = view.hotbar_offset_goal

	first = clamp(floor(view.hotbar_offset / spacing), 0, amount)
	last = clamp(ceil((view.hotbar_offset + gridwid) / spacing), 0, amount)

	if (hoverslot >= 0)
		mouse_cursor = cr_handpoint

	res = project_pack_res
	if (build_structure != null && instance_exists(build_structure))
		res = build_structure.render_res_diffuse

	// Generate only the visible previews
	var textures = [];
	res = res_eval(res)
	for (var i = first; i < last; i++)
	{
		textures[i - first] = null
		if (blocks[i][1] = "")
			continue

		var asset, state, tex;
		asset = blocks[i][0] ? mc_assets.model_name_map[?blocks[i][1]] : mc_assets.block_name_map[?blocks[i][1]]
		state = blocks[i][2]
		with (res)
			tex = res_get_asset_picker_texture(asset, state)

		textures[i - first] = tex
	}

	// Keep the hotbar inside the view
	var clipactive, clipx, clipy, clipwid, cliphei;
	clipactive = shader_clip_active
	if (clipactive)
	{
		clipx = shader_clip_x
		clipy = shader_clip_y
		clipwid = shader_clip_width
		cliphei = shader_clip_height
	}

	draw_box_rounded(xx, yy, wid, hei, c_toolbar, a_toolbar)

	clip_begin(gridx, yy + padding, gridwid, slotsize)

	shader_texture_filter_linear = false

	draw_texture_start()
	for (var i = first; i < last; i++)
	{
		var tx, ty, hovered, selected;
		tx = gridx + i * spacing - round(view.hotbar_offset)
		ty = yy + padding
		hovered = (i = hoverslot)
		selected = (i = build_hotbar_slot)

		draw_texture_done()
		draw_box_rounded(tx + 2, ty + 2, slotsize - 4, slotsize - 4, c_black, .25)

		if (selected || (hovered && mouse_left))
			draw_box_rounded(tx + 2, ty + 2, slotsize - 4, slotsize - 4, c_accent_overlay, a_accent_overlay)
		else if (hovered)
			draw_box_rounded(tx + 2, ty + 2, slotsize - 4, slotsize - 4, c_overlay, a_overlay)

		draw_texture_start()

		if (textures[i - first] != null)
			draw_texture_part(textures[i - first], tx, ty, 0, 0, slotsize, slotsize)
	}
	
	draw_texture_done()
	clip_end()
	clip_begin(content_x, content_y, content_width, content_height)

	// Hotbar controls
	var iconx, icony, prevmouseon;
	iconx = xx + padding
	icony = yy + 4
	prevmouseon = content_mouseon
	content_mouseon = (view.hotbar_mouseon && !build_drag_active)
	
	tip_set_keybind(keybind_new(vk_up))
	if (draw_button_icon("hotbar/previous", iconx, icony, 24, 24, false, icons.CHEVRON_UP, null, false, "tooltip/hotbar/previous_hotbar"))
		action_build_hotbar_scroll(-1)
	
	tip_set_keybind(keybind_new(vk_down))
	if (draw_button_icon("hotbar/next", iconx, icony + 24, 24, 24, false, icons.CHEVRON_DOWN, null, false, "tooltip/hotbar/next_hotbar"))
		action_build_hotbar_scroll(1)
	
	if (draw_button_icon("hotbar/settings", iconx, icony + 24 * 2, 24, 24, build_hotbars.show, icons.SETTINGS, null, false, "tooltip/hotbar/hotbar_settings"))
	{
		if (build_hotbars.show)
			tab_close(build_hotbars)
		else
			tab_show(build_hotbars, true)
	}

	iconx = xx + wid - padding - 24
	if (draw_button_icon("hotbar/add_slot", iconx, yy + hei / 2 - 24, 24, 24, false, icons.CUBE_ADD, null, false, "tooltip/hotbar/add_slot"))
		action_build_hotbar_slots(true)

	if (draw_button_icon("hotbar/remove_slot", iconx, yy + hei / 2, 24, 24, false, icons.CUBE_REMOVE, null, amount <= 1, "tooltip/hotbar/remove_slot"))
		action_build_hotbar_slots(false)

	if (arrowwid > 0)
	{
		draw_button_icon("hotbar/scroll_left", gridx - arrowwid, yy, arrowwid, hei, false, icons.CHEVRON_LEFT, null, view.hotbar_offset_goal <= 0)
		draw_button_icon("hotbar/scroll_right", gridx + gridwid, yy, arrowwid, hei, false, icons.CHEVRON_RIGHT, null, view.hotbar_offset_goal >= maxscroll)
	}

	content_mouseon = prevmouseon

	clip_end()

	// Draw selected slot outline
	if (build_hotbar_slot >= first && build_hotbar_slot < last)
	{
		clip_begin(gridx - 2, yy + padding - 2, gridwid + 4, slotsize + 4)
		draw_outline(gridx + build_hotbar_slot * spacing - round(view.hotbar_offset) + 2, yy + padding + 2, slotsize - 4, slotsize - 4, 4, c_hover, a_hover)
		clip_end()
	}

	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
}
