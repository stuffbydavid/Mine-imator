function view_build_hotbar_draw(view)
{
	view.hotbar_mouseon = false
	if (view != view_main || !place_build || build_hotbars.selected < 0 || build_hotbars.selected >= ds_list_size(build_hotbars.list.list))
		return 0

	var hotbar, blocks, amount, slotsize, padding, xx, yy, wid, hei, res;
	hotbar = build_hotbars.list.list[|build_hotbars.selected]
	blocks = hotbar.blocks
	amount = array_length(blocks)

	slotsize = 64
	padding = 8
	wid = amount * slotsize + padding * 2 + 56
	hei = slotsize + padding * 2
	xx = floor(content_x + (content_width - wid) / 2)
	yy = content_y + content_height - hei - 8
	
	view.hotbar_mouseon = (!build_first_person && view.mouseon && !popup_mouseon && !toast_mouseon &&
		!context_menu_mouseon && !(view_second.show && view_second.mouseon) &&
		app_mouse_box(xx, yy, wid, hei, window_busy) &&
		app_mouse_box(content_x, content_y, content_width, content_height, window_busy))

	res = project_pack_res
	if (build_structure != null && instance_exists(build_structure))
		res = build_structure.render_res_diffuse

	// Generate previews
	var textures = [];
	res = res_eval(res)
	for (var i = 0; i < amount; i++)
	{
		var asset, state, tex;
		asset = blocks[i][0] ? mc_assets.model_name_map[?blocks[i][1]] : mc_assets.block_name_map[?blocks[i][1]]
		state = blocks[i][2]
		with (res)
			tex = res_get_asset_picker_texture(asset, state)

		textures[i] = tex
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

	clip_begin(content_x, content_y, content_width, content_height)

	draw_box(xx, yy, wid, hei, false, c_toolbar, a_toolbar)

	shader_texture_filter_linear = false

	draw_texture_start()
	for (var i = 0; i < amount; i++)
	{
		var tx, ty, hovered, selected;
		tx = xx + padding + 28 + i * slotsize
		ty = yy + padding
		hovered = view.hotbar_mouseon && app_mouse_box(tx, ty, slotsize, slotsize, place_busy)
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

		if (textures[i] != null)
			draw_texture_part(textures[i], tx, ty, 0, 0, slotsize, slotsize)

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

	/*iconx += 28 + amount * slotsize + 4
	draw_button_icon("hotbar/create_slot", iconx, icony, 24, 24, false, icons.PLUS, null, false, "tooltip/hotbar/create_slot")
	draw_button_icon("hotbar/remove_slot", iconx, icony + 24, 24, 24, false, icons.DELETE, null, false, "tooltip/hotbar/remove_slot")*/
	content_mouseon = prevmouseon

	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
}
