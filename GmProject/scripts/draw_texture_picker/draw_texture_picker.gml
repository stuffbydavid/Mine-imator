/// @desc Draws a box for selecting between images from several texture sheets.
///		  The sheets share a single 32px grid. The script receives a combined slot
///		  number, whose offsets are the preceding sheet list sizes.
/// @arg picker
/// @arg select
/// @arg textures
/// @arg slots
/// @arg sheet_sizes
/// @arg x
/// @arg y
/// @arg width
/// @arg height
/// @arg script
/// @arg [namelists]
/// @arg [resource]
/// @arg [selectclick]
/// @arg [searchstretch]

function draw_texture_picker(picker, select, texlist, slots, sheetsizes, xx, yy, wid, hei, script, namelists = null, res = null, scriptselectclick = null, searchstretch = false)
{
	var scroll, off, slotwid, slothei, slotsize, itemsx, contenthei, displaycount, gridwid, gridx, maxscroll;
	var pickermouseon, previoustipslot, slotoffset, searchx, searchwid;
	scroll = picker.scroll

	searchx = xx + wid - 144
	searchwid = 144
	if (searchstretch)
	{
		searchx = xx
		searchwid = wid
	}
	
	if (draw_searchbox("texture/search" + string(scroll), searchx, yy, searchwid, picker.search_tbx, searchstretch))
	{
		picker.search = picker.search_tbx.text != ""
		picker.search_slots = null
		scroll.value = 0
		scroll.value_goal = 0
	}

	if (picker.search && picker.search_slots = null)
	{
		var searchslots, searchtext, searchid;
		searchslots = []
		searchtext = string_lower(picker.search_tbx.text)
		searchid = string_replace_all(searchtext, " ", "_")
		slotoffset = 0
		
		for (var sheet = 0; sheet < array_length(slots); sheet++)
		{
			var names = (namelists != null && sheet < array_length(namelists)) ? namelists[sheet] : null;
			if (ds_list_valid(names))
			{
				for (var slot = 0; slot < min(slots[sheet], ds_list_size(names)); slot++)
				{
					var slotname = string_lower(names[|slot]);
					if (string_pos(searchtext, slotname) > 0 || string_pos(searchid, slotname) > 0)
						array_add(searchslots, slotoffset + slot)
				}
			}
			slotoffset += slots[sheet]
		}
		picker.search_slots = searchslots
	}

	yy += list_header_height
	hei -= list_header_height
	if (hei <= 2 || wid <= 2)
		return 0
	
	// Background
	draw_box(xx + 1, yy + 1, wid - 2, hei - 2, false, c_input_background)
	
	// Outline
	if (window_focus = string(scroll))
	{
		draw_outline(xx, yy, wid, hei, 1, c_accent, 1, true)
		window_scroll_focus = string(scroll)

		if (!app_mouse_box(xx, yy, wid, hei) && content_mouseon && mouse_left && window_busy != "scrollbar")
			window_focus = ""
	}
	else
		draw_outline(xx, yy, wid, hei, 1, c_border, a_border, true)
	
	off = 1
	slotwid = 32
	slothei = 32
	slotsize = slotwid + off * 2
	
	displaycount = picker.search ? array_length(picker.search_slots) : 0
	if (!picker.search)
		for (var sheet = 0; sheet < array_length(slots); sheet++)
			displaycount += slots[sheet]
	
	gridwid = max(1, wid - 2)
	itemsx = max(1, floor(gridwid / slotsize))
	
	scroll.needed = (ceil(displaycount / itemsx) * slotsize > hei - 2)
	if (scroll.needed)
	{
		gridwid = max(1, gridwid - 14)
		itemsx = max(1, floor(gridwid / slotsize))
	}
	
	contenthei = ceil(displaycount / itemsx) * slotsize
	gridx = xx + 1 + max(0, floor((gridwid - itemsx * slotsize) / 2))
	maxscroll = max(0, contenthei - hei + 2)
	scroll.value = clamp(scroll.value, 0, maxscroll)
	scroll.value_goal = clamp(scroll.value_goal, 0, maxscroll)
	pickermouseon = app_mouse_box(xx + 1, yy + 1, gridwid, hei - 2) && content_mouseon
	previoustipslot = picker.tip_slot
	picker.tip_slot = -1

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

	var firstslot, lastslot;
	firstslot = clamp(floor(scroll.value / slotsize) * itemsx, 0, displaycount)
	lastslot = clamp(ceil((scroll.value + hei) / slotsize) * itemsx, 0, displaycount)

	shader_texture_filter_linear = false
	draw_texture_start()
	
	for (var displayslot = firstslot; displayslot < lastslot; displayslot++)
	{
		var combinedslot, sheet, slot, tex, sheetsize, tx, ty, col;
		combinedslot = picker.search ? picker.search_slots[displayslot] : displayslot
		sheet = 0
		slot = combinedslot
		while (sheet < array_length(slots) && slot >= slots[sheet])
		{
			slot -= slots[sheet]
			sheet++
		}
		if (sheet >= array_length(slots))
			continue

		tex = texlist[sheet]
		sheetsize = sheetsizes[sheet]
		if (tex = null || sheetsize[X] <= 0 || sheetsize[Y] <= 0)
			continue

		tx = gridx + (displayslot mod itemsx) * slotsize
		ty = floor(yy + 1 - scroll.value + (displayslot div itemsx) * slotsize)

		col = c_white
		if (res != null && namelists != null && ds_list_valid(namelists[sheet]))
			col = block_texture_get_blend(namelists[sheet][|slot], res)

		// Keep the selection behind the cell texture
		if (select = combinedslot)
		{
			draw_texture_done()
			draw_box(tx, ty, slotsize, slotsize, false, c_accent_hover, a_accent_hover)
			draw_texture_start()
		}

		draw_texture_slot(tex, slot, tx + off, ty + off, slotwid, slothei, sheetsize[X], sheetsize[Y], col, true)
		
		if (pickermouseon && app_mouse_box(tx, ty, slotsize, slotsize))
		{
			if (previoustipslot != combinedslot)
				picker.tip_time = current_time
			
			picker.tip_slot = combinedslot
			
			if (namelists != null && ds_list_valid(namelists[sheet]) && slot < ds_list_size(namelists[sheet]) && current_time - picker.tip_time >= 250)
				tip_set(minecraft_texture_get_name(namelists[sheet][|slot]), tx, ty, slotsize, slotsize)

			mouse_cursor = cr_handpoint
			if (mouse_left_pressed)
			{
				if (combinedslot = select && window_focus = string(scroll) && scriptselectclick != null)
				{
					script_execute(scriptselectclick)
					if (scriptselectclick = action_bench_create)
					{
						bench_show_ani_type = "hide"
						app_mouse_clear()
					}
				}
				else
					script_execute(script, combinedslot)

				// Restore drawing after the selection callback updates a preview
				draw_texture_start()
				
				window_focus = string(scroll)
				
				select = combinedslot
			}
		}
	}
	
	draw_texture_done()
	
	clip_end()
	if (clipactive)
		clip_begin(clipx, clipy, clipwid, cliphei)
	
	// Scrollbar
	scroll.snap_value = slotsize
	scrollbar_draw(scroll, e_scroll.VERTICAL, xx + wid - 12, yy + 1, hei - 2, contenthei)
}
