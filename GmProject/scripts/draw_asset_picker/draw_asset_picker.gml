/// @desc Draws asset previews with shared compatible state choices.
/// @arg resource
/// @arg picker
/// @arg select
/// @arg state
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg [name]

function draw_asset_picker(res, picker, select, state, xx, yy, wid, hei, name = "")
{
	// List mode, including header
	if (!picker.grid_view)
		return sortlist_draw(picker, xx, yy, wid, hei, select, false, name, state)

	// Header
	if (!draw_list_header(picker, xx, yy, wid, hei, false, name))
		return select

	var searchunfocused = (picker.search_focused && window_focus != string(picker.search_tbx));
	picker.search_focused = (window_focus = string(picker.search_tbx))

	yy += list_header_height
	hei -= list_header_height
	if (hei <= 2 || wid <= 2)
		return select

	// Fit grid columns and leave room for the scrollbar
	var cell, columns, count, contenthei, gridwid, gridx, maxscroll;
	cell = 72
	count = ds_list_size(picker.display_list)
	columns = max(1, floor((wid - 2) / cell))
	picker.scroll.needed = (ceil(count / columns) * cell > hei - 2)
	gridwid = max(1, wid - 2 - 14 * picker.scroll.needed)
	columns = max(1, floor(gridwid / cell))
	contenthei = ceil(count / columns) * cell
	gridx = xx + 1 + max(0, floor((gridwid - columns * cell) / 2))
	maxscroll = max(0, contenthei - hei + 2)
	picker.view_height = hei - 2
	picker.items_visible = max(1, floor((hei - 2) / cell)) * columns

	// Reveal the selected block after searching, scrolling or picking an existing block
	if (picker.grid_view && (picker.view_value != null || picker.center_on_draw || searchunfocused || (picker.search_changed && !picker.search)))
	{
		var target, index;
		target = (picker.view_value != null ? picker.view_value : select)
		index = ds_list_find_index(picker.display_list, target)
		
		if (index >= 0)
		{
			var top = (index div columns) * cell;
			if (picker.center_on_draw)
				picker.scroll.value_goal = top - floor((hei - 2 - cell) / 2)
			else if (top < picker.scroll.value_goal)
				picker.scroll.value_goal = top
			else if (top + cell > picker.scroll.value_goal + hei - 2)
				picker.scroll.value_goal = top + cell - hei + 2
			
			picker.scroll.value = clamp(picker.scroll.value_goal, 0, maxscroll)
		}
		
		picker.view_value = null
		picker.center_on_draw = false
	}
	
	picker.scroll.value = clamp(picker.scroll.value, 0, maxscroll)
	picker.scroll.value_goal = clamp(picker.scroll.value_goal, 0, maxscroll)

	// Resolve visible states and generate thumbnails
	var first, last, textures, states, search, prevalpha, prevcolor, prevfont;
	first = clamp(floor(picker.scroll.value / cell) * columns, 0, count)
	last = clamp(ceil((picker.scroll.value + hei - 2) / cell) * columns, 0, count)
	textures = []
	states = []
	search = string_lower(picker.search_tbx.text)
	prevalpha = draw_get_alpha()
	prevcolor = draw_get_color()
	prevfont = draw_get_font()
	res = res_eval(res)
	
	for (var i = first; i < last; i++)
	{
		var value, asset, vars, texture;
		value = picker.display_list[|i]
		if (is_array(value))
			asset = value[0] ? mc_assets.model_name_map[?value[1]] : mc_assets.block_name_map[?value[1]]
		else
			asset = picker.asset_picker_model ? mc_assets.model_name_map[?value] : mc_assets.block_name_map[?value]
		
		vars = asset_picker_get_state(asset, search)
		if (select = value && search = "")
			vars = minecraft_asset_get_state(asset, state)
		with (res)
			texture = res_get_asset_picker_texture(asset, vars)
		
		textures[i - first] = texture
		states[i - first] = vars
	}
	
	draw_set_alpha(prevalpha)
	draw_set_color(prevcolor)
	draw_set_font(prevfont)

	// Preserve the surrounding clip while drawing the picker
	draw_box(xx + 1, yy + 1, wid - 2, hei - 2, false, c_input_background, draw_get_alpha())
	draw_outline(xx, yy, wid, hei, 1, window_focus = string(picker.scroll) ? c_accent : c_border, window_focus = string(picker.scroll) ? 1 : a_border, true)
	
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

	// Draw selectable images and delayed asset names
	var mouseon, previoustip;
	mouseon = app_mouse_box(xx + 1, yy + 1, gridwid, hei - 2) && content_mouseon
	previoustip = picker.scroll.picker_tip_slot
	picker.scroll.picker_tip_slot = -1
	shader_texture_filter_linear = false
	
	draw_texture_start()
	
	for (var i = first; i < last; i++)
	{
		var value, tx, ty, hovered, selected, texture;
		value = picker.display_list[|i]
		tx = gridx + (i mod columns) * cell
		ty = floor(yy + 1 + (i div columns) * cell - picker.scroll.value)
		hovered = mouseon && app_mouse_box(tx, ty, cell, cell)
		selected = (select = value)
		
		if (selected || hovered)
		{
			draw_texture_done()
			draw_box(tx, ty, cell, cell, false, selected ? c_accent_overlay : c_overlay, selected ? a_accent_overlay : a_overlay)
			draw_texture_start()
		}
		
		texture = textures[i - first]
		if (texture != null)
			draw_texture_part(texture, tx + 4, ty + 4, 0, 0, 64, 64)
		
		if (!hovered)
			continue
		
		mouse_cursor = cr_handpoint
		
		if (previoustip != i)
			picker.scroll.picker_tip_time = current_time
		
		picker.scroll.picker_tip_slot = i
		
		if (current_time - picker.scroll.picker_tip_time >= 250)
			tip_set(sortlist_column_get(picker, value, 0), tx, ty, cell, cell)
		
		if (mouse_left_released && picker.script != null)
		{
			draw_texture_done()
			
			if (selected && window_focus = string(picker.scroll) && picker.script_select_click != null)
			{
				script_execute(picker.script, value, states[i - first])
				script_execute(picker.script_select_click)
				if (picker.script_select_click = action_bench_create)
					bench_show_ani_type = "hide"
			}
			else
				script_execute(picker.script, value, states[i - first])
			
			select = value
			window_focus = string(picker.scroll)
			
			app_mouse_clear()
			draw_texture_start()
		}
	}
	
	draw_texture_done()
	
	clip_end()
	
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)

	// Scroll by one row with each wheel step
	picker.scroll.snap_value = 0
	picker.scroll.wheel_speed = cell
	
	scrollbar_draw(picker.scroll, e_scroll.VERTICAL, xx + wid - 12, yy + 1, hei - 2, contenthei)
	
	if (content_mouseon)
		window_scroll_focus = string(picker.scroll)
	
	return select
}
