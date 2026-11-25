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

	if (build_hotbars.selected < 0 || build_hotbars.selected >= ds_list_size(build_hotbars.list.list))
		return 0

	var hotbar, blocks, amount, slotsize, padding, xx, yy, wid, hei, res;
	var arrowwid, gridx, gridwid, maxscroll, first, last;
	hotbar = build_hotbars.list.list[|build_hotbars.selected]
	blocks = hotbar.blocks
	amount = array_length(blocks)

	slotsize = 64
	padding = 8
	wid = min(amount * slotsize + padding * 2 + 56, content_width - 32)
	hei = slotsize + padding * 2
	arrowwid = (amount * slotsize + padding * 2 + 56 > wid ? 24 : 0)
	gridwid = wid - padding * 2 - 56 - arrowwid * 2
	if (gridwid <= 0 || content_height < hei + 8)
		return 0

	xx = floor(content_x + (content_width - wid) / 2)
	yy = content_y + content_height - hei - 8
	view.hotbar_x = xx
	gridx = xx + padding + 28 + arrowwid
	
	view.hotbar_mouseon = (!build_first_person && view.mouseon && !popup_mouseon && !toast_mouseon &&
		!context_menu_mouseon && !(view_second.show && view_second.mouseon) &&
		app_mouse_box(xx, yy, wid, hei, window_busy) &&
		app_mouse_box(content_x, content_y, content_width, content_height, window_busy))

	// Scroll while holding either arrow and snap in that direction on release
	var dir = 0;
	if (arrowwid > 0 && view.hotbar_mouseon && mouse_left)
	{
		if (app_mouse_box(gridx - arrowwid, yy, arrowwid, hei, place_busy))
			dir = -1
		else if (app_mouse_box(gridx + gridwid, yy, arrowwid, hei, place_busy))
			dir = 1
	}

	maxscroll = max(0, amount * slotsize - gridwid)
	view.hotbar_offset = clamp(view.hotbar_offset, 0, maxscroll)
	view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
	
	if (dir != 0)
		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal + dir * 8 * delta, 0, maxscroll)
	else if (view.hotbar_scroll_direction != 0)
	{
		if (view.hotbar_scroll_direction > 0)
			view.hotbar_offset_goal = ceil(view.hotbar_offset / slotsize) * slotsize
		else
			view.hotbar_offset_goal = floor(view.hotbar_offset / slotsize) * slotsize

		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
	}
	view.hotbar_scroll_direction = dir

	// Reveal selections made with the mouse wheel, number keys or block picking
	if (view.hotbar_selected != hotbar || view.hotbar_slot != build_hotbar_slot)
	{
		if (view.hotbar_selected != hotbar)
		{
			view.hotbar_offset = 0
			view.hotbar_offset_goal = 0
		}

		if (build_hotbar_slot * slotsize < view.hotbar_offset_goal)
			view.hotbar_offset_goal = build_hotbar_slot * slotsize
		else if ((build_hotbar_slot + 1) * slotsize > view.hotbar_offset_goal + gridwid)
			view.hotbar_offset_goal = ceil(((build_hotbar_slot + 1) * slotsize - gridwid) / slotsize) * slotsize

		view.hotbar_offset_goal = clamp(view.hotbar_offset_goal, 0, maxscroll)
		view.hotbar_selected = hotbar
		view.hotbar_slot = build_hotbar_slot
	}

	view.hotbar_offset += (view.hotbar_offset_goal - view.hotbar_offset) / max(1, 4 / delta)
	if (abs(view.hotbar_offset_goal - view.hotbar_offset) < .5)
		view.hotbar_offset = view.hotbar_offset_goal

	first = clamp(floor(view.hotbar_offset / slotsize), 0, amount)
	last = clamp(ceil((view.hotbar_offset + gridwid) / slotsize), 0, amount)

	res = project_pack_res
	if (build_structure != null && instance_exists(build_structure))
		res = build_structure.render_res_diffuse

	// Generate only the visible previews
	var textures = [];
	res = res_eval(res)
	for (var i = first; i < last; i++)
	{
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
		tx = gridx + i * slotsize - round(view.hotbar_offset)
		ty = yy + padding
		hovered = (view.hotbar_mouseon &&
			app_mouse_box(gridx, ty, gridwid, slotsize, place_busy) &&
			app_mouse_box(tx, ty, slotsize, slotsize, place_busy))
		selected = (i = build_hotbar_slot)

		if (selected || (hovered && mouse_left))
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

		if (textures[i - first] != null)
			draw_texture_part(textures[i - first], tx, ty, 0, 0, slotsize, slotsize)

		if (!hovered)
			continue

		mouse_cursor = cr_handpoint
		if (mouse_left_released)
		{
			draw_texture_done()
			action_build_hotbar_select(i)
			draw_texture_start()
		}
	}
	
	draw_texture_done()
	clip_end()
	clip_begin(content_x, content_y, content_width, content_height)

	// Hotbar controls
	var iconx, icony, prevmouseon;
	iconx = xx + padding
	icony = yy + 4
	prevmouseon = content_mouseon
	content_mouseon = view.hotbar_mouseon
	
	if (draw_button_icon("hotbar/previous", iconx, icony, 24, 24, false, icons.CHEVRON_UP, null, false, "tooltip/hotbar/previous_hotbar"))
		action_build_hotbar_scroll(-1)
	
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
	if (draw_button_icon("hotbar/create_slot", iconx, yy + hei / 2 - 24, 24, 24, false, icons.HOTBAR_ADD, null, false, "tooltip/hotbar/create_slot"))
		action_build_hotbar_slots(true)

	if (draw_button_icon("hotbar/remove_slot", iconx, yy + hei / 2, 24, 24, false, icons.HOTBAR_REMOVE, null, amount <= 1, "tooltip/hotbar/remove_slot"))
		action_build_hotbar_slots(false)

	if (arrowwid > 0)
	{
		draw_button_icon("hotbar/scroll_left", gridx - arrowwid, yy, arrowwid, hei, false, icons.CHEVRON_LEFT, null, view.hotbar_offset_goal <= 0)
		draw_button_icon("hotbar/scroll_right", gridx + gridwid, yy, arrowwid, hei, false, icons.CHEVRON_RIGHT, null, view.hotbar_offset_goal >= maxscroll)
	}

	content_mouseon = prevmouseon

	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
}
